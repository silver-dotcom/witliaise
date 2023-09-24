import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(LoginPage());

class ScaffoldSnackbar {
  ScaffoldSnackbar(this._context);
  final BuildContext _context;

  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontSize: 16)),
          backgroundColor: Color(0xFF404040),
          duration: Duration(milliseconds: 2000),
          width: MediaQuery.of(_context).size.width * 0.9,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 17, vertical: 16),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isHidden = true;
  bool isTeacher = false;

  studentOrTeacher() {
    _firestore
        .collection('teacher')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists)
        // {
        //   isTeacher = true;
        // }
        setState(() {
          if (documentSnapshot.exists) {
            isTeacher = true;
          }
        });
    });
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    String email = '', pass = '';
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
      children: <Widget>[
        Container(
          height: 480,
          // height: MediaQuery.of(context).size.height * 0.586,
          // width: MediaQuery.of(context).size.width,
          width: 480,
          child: Image.asset(
            'images/loginpage.png',
            // height: MediaQuery.of(context).size.height * 0.586,
            // height: 480,
            fit: BoxFit.cover,
          ),
        ),
        // Image.asset(
        //   'images/loginpage.png',
        //   // height: MediaQuery.of(context).size.height * 0.586,
        //   height: 480,
        //   fit: BoxFit.cover,
        // ),
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.all(15),
          child: TextField(
            cursorColor: Colors.black12,
            onChanged: (value) {
              email = value;
            },
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber, width: 2),
              ),
              border: OutlineInputBorder(),
              labelText: 'Email',
              floatingLabelStyle: TextStyle(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              hintText: 'Enter Your Email',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 15, left: 15, right: 15),
          child: TextField(
            cursorColor: Colors.black12,
            onChanged: (value) {
              pass = value;
            },
            obscureText: _isHidden,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber, width: 2),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.all(5),
                child: IconButton(
                  onPressed: _togglePasswordView,
                  icon: Icon(
                    _isHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.black45,
                  ),
                ),
              ),
              border: OutlineInputBorder(),
              labelText: 'Password',
              floatingLabelStyle: TextStyle(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              hintText: 'Enter Password',
            ),
          ),
        ),
        SizedBox(
          width: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
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
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      primary: Colors.black54,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () async {
                      try {
                        List<Map<String, dynamic>> membersList = [];
                        bool isAlreadyExist = false;
                        String? username;

                        await _auth.signInWithEmailAndPassword(
                            email: email.trim(), password: pass);
                        studentOrTeacher();

                        if (isTeacher == false) {
                          await _firestore
                              .collection('student')
                              .doc(_auth.currentUser!.uid)
                              .get()
                              .then((map) {
                            for (int i = 0; i < membersList.length; i++) {
                              if (membersList[i] == _auth.currentUser) {
                                isAlreadyExist = true;
                              }
                            }
                            if (!isAlreadyExist) {
                              setState(() {
                                membersList.add({
                                  "student_name": map['student_name'],
                                  "student_class": map['student_class'],
                                  "student_address": map['student_address'],
                                  "student_phone_number":
                                      map['student_phone_number'],
                                });
                              });
                            }
                          });

                          await _firestore
                              .collection('student')
                              .doc(_auth.currentUser!.uid)
                              .get()
                              .then((value) {
                            username = value['student_name'];
                          });
                          await _auth.currentUser!.updateDisplayName(username);

                          for (int index = 0;
                              index < membersList.length;
                              index++) {
                            if (membersList[index]['student_class'] == 'fyit') {
                              await _firestore
                                  .collection('groups')
                                  .doc('fyit')
                                  .update({
                                "members": FieldValue.arrayUnion(membersList)
                              });
                            } else if (membersList[index]['student_class'] ==
                                'syit') {
                              await _firestore
                                  .collection('groups')
                                  .doc('syit')
                                  .update({
                                "members": FieldValue.arrayUnion(membersList)
                              });
                            } else if (membersList[index]['student_class'] ==
                                'tyit') {
                              await _firestore
                                  .collection('groups')
                                  .doc('tyit')
                                  .update({
                                "members": FieldValue.arrayUnion(membersList)
                              });
                            }
                          }
                        } else {
                          await _firestore
                              .collection('teacher')
                              .doc(_auth.currentUser!.uid)
                              .get()
                              .then((map) {
                            for (int i = 0; i < membersList.length; i++) {
                              if (membersList[i] == _auth.currentUser) {
                                isAlreadyExist = true;
                              }
                            }
                            if (!isAlreadyExist) {
                              setState(() {
                                membersList.add({
                                  "teacher_name": map['teacher_name'],
                                  "teacher_email": map['teacher_email'],
                                  "teacher_address": map['teacher_address'],
                                  "teacher_phone_number":
                                      map['teacher_phone_number'],
                                });
                              });
                            }
                          });
                          await _firestore
                              .collection('teacher')
                              .doc(_auth.currentUser!.uid)
                              .get()
                              .then((value) {
                            username = value['teacher_name'];
                          });
                          await _auth.currentUser!.updateDisplayName(username);

                          for (int index = 0;
                              index < membersList.length;
                              index++) {
                            await _firestore
                                .collection('groups')
                                .doc('fyit')
                                .update({
                              "members": FieldValue.arrayUnion(membersList)
                            });
                            await _firestore
                                .collection('groups')
                                .doc('syit')
                                .update({
                              "members": FieldValue.arrayUnion(membersList)
                            });
                            await _firestore
                                .collection('groups')
                                .doc('tyit')
                                .update({
                              "members": FieldValue.arrayUnion(membersList)
                            });
                            await _firestore
                                .collection('groups')
                                .doc('faculties')
                                .update({
                              "members": FieldValue.arrayUnion(membersList)
                            });
                          }
                        }
                        Navigator.pushNamed(context, 'main');
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          ScaffoldSnackbar.of(context).show(
                              'User not found! Failed to sign in with email & password!');
                        } else if (e.code == 'invalid-email') {
                          ScaffoldSnackbar.of(context)
                              .show('Invalid email! Please type valid email!');
                        } else if (e.code == 'wrong-password') {
                          ScaffoldSnackbar.of(context).show(
                              'Incorrect password! Please type valid password!');
                        }
                      }
                    },
                    child: const Text('Log In'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.zero,
          child: TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
              minimumSize: Size.zero,
            ),
            onPressed: () => Navigator.pushNamed(context, 'forgotpwd'),
            child: const Text('Forgot Password?'),
          ),
        ),
      ],
    ))));
  }
}
