import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:sample/Authenticate.dart';
import 'package:sample/Calendar/CreateEventPage.dart';
import 'package:sample/Forum/ForumPage.dart';
import 'package:sample/Login/forgotpwd.dart';
import 'package:sample/MainPage.dart';
import 'package:sample/Login/LoginPage.dart';
import 'package:sample/Forum/CreateThreadPage.dart';
import 'package:sample/Cloud/Retrieve.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'auth',
      routes: {
        'auth': (context) => Authenticate(),
        'login': (context) => LoginPage(),
        'forgotpwd': (context) => Forgotpwd(),
        'main': (context) => MainPage(),
        'forum': (context) => ForumPage(),
        'createthread': (context) => CreateThreadPage(),
        'createevent': (context) => CreateEventPage(),
        'retrieve': (context) => Retrieve()
      }));
}
