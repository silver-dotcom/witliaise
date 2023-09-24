import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample/Calendar/CalendarPage.dart';
import 'package:sample/Cloud/Retrieve.dart';
import 'package:sample/Forum/ForumPage.dart';
import 'package:sample/GroupChat/GroupChatScreen.dart';
import 'package:sample/GroupChat/GroupSelectionScreen.dart';
import 'package:sample/Login/LoginPage.dart';
import 'package:sample/ProfilePage.dart';

void main() => runApp(MainPage());

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isTeacher = false;
  String groupChatId = '';

  studentOrTeacher() {
    FirebaseFirestore.instance
        .collection('teacher')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        isTeacher = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    studentOrTeacher();
    if (isTeacher == false) {
      FirebaseFirestore.instance
          .collection("student")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          groupChatId = value['student_class'];
        });
      });
    }
  }

  Widget buildpages() {
    switch (_selectedIndex) {
      case 0:
        return ForumPage();
      case 1:
        if (isTeacher == false)
          return GroupChatScreen(groupChatId, false);
        else
          return GroupSelectionScreen();
      case 2:
        return CalendarPage(isTeacher);
      case 3:
        return Retrieve();
      default:
        return MainPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: Container(
        width: 250,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD900),
                ),
                child: Text(
                  'Welcome, ${FirebaseAuth.instance.currentUser!.displayName}!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.account_circle_sharp, size: 35),
                title: Text('Profile', style: TextStyle(fontSize: 15)),
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(isTeacher)));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, size: 35),
                title: Text('Log Out', style: TextStyle(fontSize: 15)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamed(context, 'login');
                  ScaffoldSnackbar.of(context)
                      .show('You have been successfully logged out');
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Witliaise', style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFFC1C1C1),
        iconTheme: IconThemeData(color: Colors.black),
        leading: Padding(
          padding: EdgeInsets.only(left: 12),
          child: Image.asset('images/witliaiseicon.png'),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            backgroundColor: Color(0xFFE1E1E1),
            minExtendedWidth: 360,
            selectedIndex: _selectedIndex,
            selectedIconTheme: IconThemeData(
              color: Color(0xFF000000),
            ),
            selectedLabelTextStyle: TextStyle(
              color: Colors.black45,
              fontSize: 14,
            ),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.forum_outlined),
                selectedIcon: Icon(Icons.forum_sharp),
                label: Text('Forum'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.group_outlined),
                selectedIcon: Icon(Icons.group_sharp),
                label: Text('Groups'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: Text('Calendar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.cloud_download),
                selectedIcon: Icon(Icons.cloud_upload_rounded),
                label: Text('Cloud'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: buildpages()),
        ],
      ),
    );
  }
}
