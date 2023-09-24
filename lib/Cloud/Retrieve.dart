import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/Cloud/Services/CloudServices.dart';
import 'package:sample/Login/LoginPage.dart';
import 'package:sample/Cloud/Model/firebase_file.dart';
import 'package:path/path.dart';
import 'package:sample/Cloud/Widget/refresh_widget.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await Firebase.initializeApp();
}

class Retrieve extends StatefulWidget {
  const Retrieve({Key? key}) : super(key: key);

  @override
  _RetrievePageState createState() => _RetrievePageState();
}

class _RetrievePageState extends State<Retrieve> {
  late Future<List<FirebaseFile>> futureFiles;
  var firebaseUser = FirebaseAuth.instance.currentUser;
  CloudServices ap = CloudServices();
  bool isSelected = true;
  UploadTask? task;
  File? file;

  final retrieve = 'file/${FirebaseAuth.instance.currentUser!.displayName}';
  static downloadingCallback(id, status, progress) {}
  final GlobalKey<RefreshIndicatorState> rikey =
      GlobalKey<RefreshIndicatorState>(debugLabel: '_Retrieveform');

  @override
  void initState() {
    super.initState();
    FlutterDownloader.registerCallback(downloadingCallback);
    loadList();
  }

  Future loadList() async {
    setState(() {
      futureFiles = ap.listAll(retrieve);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: FloatingActionButton(
            backgroundColor: Colors.amber,
            onPressed: () {
              selectandUploadFile();
              ScaffoldSnackbar.of(context).show('File Uploaded Successfully');
            },
            child: Icon(
              Icons.add,
              color: Colors.black54,
              size: 40,
            ),
          ),
        ),
        body: FutureBuilder<List<FirebaseFile>>(
          future: futureFiles,
          builder: (context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                    child: CircularProgressIndicator(color: Colors.amber));

              default:
                if (snapshot.hasError) {
                  loadList();
                  return Center(
                      child: CircularProgressIndicator(color: Colors.amber));
                } else {
                  final files = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(files.length),
                      const SizedBox(height: 12),
                      Expanded(
                        child: RefreshWidget(
                          keyRefresh: rikey,
                          onRefresh: loadList,
                          child: ListView.builder(
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              final file = files[index];

                              return scrollpage(context, file);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
            }
          },
        ),
      );
  Widget buildHeader(int length) => ListTile(
        tileColor: Colors.amber,
        leading: Container(
          width: 52,
          height: 52,
          child: Icon(
            Icons.file_copy,
            color: Colors.black38,
          ),
        ),
        title: Text(
          '$length Files',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      );
// --------selecting a file from storage------------
  Future selectandUploadFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    final status = await Permission.storage.request();
    if (status.isGranted) {
      if (result == null) return;
      final path = result.files.single.path!;
      setState(() => file = File(path));

      if (file == null) return;
      final fileName = basename(file!.path);
      final destination =
          'file/${FirebaseAuth.instance.currentUser!.displayName}/$fileName'; //The part where we need a new folder
      //for every new student
      task = CloudServices.uploadFile(destination, file!);
      loadList();
    }
  }

  Widget scrollpage(BuildContext context, FirebaseFile file) =>
      Column(children: [
        ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 1.5, horizontal: 14.0),
            title: Text(
              file.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Colors.black54,
              ),
            ),
            onTap: () =>
                CloudServices.openFile(url: file.url, filename: file.name),
            onLongPress: () {
              const FractionallySizedBox();
              showDialog<void>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                          title: const Text(
                              'Do you want to download or delete the file?'),
                          children: <Widget>[
                            SimpleDialogOption(
                              child: Text('Download'),
                              onPressed: () {
                                CloudServices.downloadFile(
                                    url: file.url, filename: file.name);
                                ScaffoldSnackbar(context)
                                    .show('File Downloaded Successfully');
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                            ),
                            SimpleDialogOption(
                              child: Text('Delete'),
                              onPressed: () {
                                ap.deleteFile(
                                    url: file.url, filename: file.url);
                                ScaffoldSnackbar(context)
                                    .show('File Deleted Successfully');

                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                loadList();
                              },
                            )
                          ]));
            })
      ]);
}
