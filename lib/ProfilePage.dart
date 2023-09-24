import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  bool isTeacher;
  ProfilePage(this.isTeacher);
  // const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // bool isTeacher = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
      bucket: 'gs://flutterfirebase-7ea40.appspot.com');
  Uint8List imageBytes = Uint8List(10000000);

  _ProfilePageState() {
    _storage
        .ref()
        .child('images/${FirebaseAuth.instance.currentUser!.uid}.png')
        .getData(10000000)
        .then((data) => setState(() {
              imageBytes = data!;
            }))
        .catchError((e) => setState(() async {
              Uint8List bytes = (await rootBundle.load('images/icon.png'))
                  .buffer
                  .asUint8List();
              imageBytes = bytes;
            }));
  }

  String name = '', sclass = '', number = '', address = '', temail = '';

  UploadTask? _uploadTask;
  File? _pickedImage;
  File? pimg;

  get buffer => null;

  @override
  void initState() {
    super.initState();
  }

  void uploadImage(ImageSource imageSource) async {
    final pickedImage = await ImagePicker().pickImage(source: imageSource);
    final pickedImageFile = File(pickedImage!.path);
    String filePath = 'images/${FirebaseAuth.instance.currentUser!.uid}.png';
    setState(() {
      _pickedImage = pickedImageFile;
      _uploadTask = _storage.ref().child(filePath).putFile(_pickedImage!);
    });
    _ProfilePageState;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (widget.isTeacher == false) {
        _firestore
            .collection("student")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) {
          setState(() {
            name = value['student_name'];
            sclass = value['student_class'];
            number = value['student_phone_number'];
            address = value['student_address'];
          });
        });
      } else {
        _firestore
            .collection("teacher")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) {
          setState(() {
            name = value['teacher_name'];
            temail = value['teacher_email'];
            number = value['teacher_phone_number'];
            address = value['teacher_address'];
          });
        });
      }
    } on FirebaseAuthException catch (e) {
      print(e);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black54),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: 0.6,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0xFFFFD900),
                      Color(0xFFFADE3E),
                      Color(0xFFFFF700),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Align(
                        alignment: Alignment(0.0, -0.2),
                        child: CircleAvatar(
                          backgroundColor: Color(0xFFF5F6F9),
                          radius: 173,
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF757575),
                            radius: 167,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 160,
                              backgroundImage: MemoryImage(imageBytes),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 60,
                      bottom: 100,
                      child: SizedBox(
                        height: 85,
                        width: 85,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                              side: BorderSide(
                                color: Color(0xFF757575),
                                width: 4,
                              ),
                            ),
                            primary: Colors.white,
                            backgroundColor: Color(0xFFF5F6F9),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 65,
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          ElevatedButton(
                                            onPressed: () =>
                                                uploadImage(ImageSource.camera),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      Colors.transparent),
                                              elevation: MaterialStateProperty
                                                  .all<double>(0.0),
                                            ),
                                            child: Icon(
                                              Icons.camera_outlined,
                                              color: Color(0xFF757575),
                                              size: 43,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => uploadImage(
                                                ImageSource.gallery),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      Colors.transparent),
                                              elevation: MaterialStateProperty
                                                  .all<double>(0.0),
                                            ),
                                            child: Icon(
                                              Icons.photo_library_outlined,
                                              color: Color(0xFF757575),
                                              size: 43,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width: 12),
                                          Text(
                                            "Camera",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF757575),
                                            ),
                                          ),
                                          SizedBox(width: 29),
                                          Text(
                                            "Gallery",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF757575),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            color: Color(0xFF757575),
                            size: 45,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(35.0),
                      topLeft: Radius.circular(35.0)),
                  color: Colors.white,
                ),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 25),
                    InfoCard(icon: Icons.person_outline, text: name),
                    sclass == ''
                        ? InfoCard(icon: Icons.mail_outline, text: temail)
                        : InfoCard(
                            icon: Icons.library_books_outlined,
                            text: sclass.toUpperCase()),
                    InfoCard(icon: Icons.phone_in_talk_outlined, text: number),
                    InfoCard(icon: Icons.home_outlined, text: address),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
        child: ListTile(
          leading: Icon(
            icon,
            size: 30,
            color: Color(0xFF757575),
          ),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}
