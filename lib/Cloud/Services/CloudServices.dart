import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:open_file/open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sample/Cloud/Model/firebase_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class CloudServices {
  static Future<List<String>> _getDownloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  Future<List<FirebaseFile>> listAll(path) async {
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();

    final urls = await _getDownloadLinks(result.items);

    return urls
        .asMap()
        .map((index, url) {
          final ref = result.items[index];
          final name = ref.name;
          final file = FirebaseFile(ref: ref, name: name, url: url);

          return MapEntry(index, file);
        })
        .values
        .toList();
  }

  static Future<File?> displayFile(String url, String name) async {
    final appstorage = await getApplicationDocumentsDirectory();
    final file = File('${appstorage.path}/$name');
    final response = await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        receiveTimeout: 0,
      ),
    );
    final raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
    return file;
  }

  //open file
  static Future openFile({required String url, String? filename}) async {
    final file = await displayFile(url, filename!);
    if (file == null) return;

    //Navigator.pop(true);
    //print('Path: ${file.path}');

    OpenFile.open(file.path);
  }

  //Deleting a file from cloud storage
  Future deleteFile({required String url, String? filename}) async {
    try {
      FirebaseStorage.instance.refFromURL(url).delete();
    } catch (e) {
      print('Failed');
    }
    // ScaffoldSnackbar.of(context).show('File Deleted Successfully');
    //Navigator.of(context).push(true);
    //Navigator.pop(context);
  }

  //Downloading a file from cloud storage
  static Future downloadFile({required String url, String? filename}) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      var externaldir = await getExternalStorageDirectory();
      var idir = '/storage/Android/Witliase';

      final id = await FlutterDownloader.enqueue(
          url: url,
          savedDir: externaldir!.path,
          showNotification: true,
          openFileFromNotification: true);
      debugPrint(id);
      print(externaldir.path);
    } else {
      print("Permission denied");
    }
  }

// uploading a file to the cloud storage
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      print(e);
    }
  }
}
