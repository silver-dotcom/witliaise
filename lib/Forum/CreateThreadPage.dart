import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sample/Forum/Models/thread.dart';
import 'package:sample/Forum/Services/ForumServices.dart';
import 'package:sample/Login/LoginPage.dart';

class CreateThreadPage extends StatefulWidget {
  @override
  _CreateThreadPageState createState() => _CreateThreadPageState();
}

class _CreateThreadPageState extends State<CreateThreadPage> {
  late String postedBy, title, desc;

  Thread thread = Thread(0, "", "", "");

  CrudMethods crudMethods = new CrudMethods();

  uploadForum() async {
    postedBy = FirebaseAuth.instance.currentUser!.displayName!;
    thread.postedBy = postedBy;
    thread.date = DateTime.now().millisecondsSinceEpoch;
    String date = thread.date.toString();
    Map<String, dynamic> forumMap = {
      "postedBy": thread.postedBy,
      "title": thread.title,
      "desc": thread.desc,
      "date": thread.date
    };
    crudMethods.addData(forumMap, date).then((result) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.file_upload_outlined,
              size: 30,
            ),
            onPressed: () {
              if (thread.title == "" || thread.desc == "")
                ScaffoldSnackbar.of(context).show('Please enter all fields!');
              else
                uploadForum();
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            SizedBox(height: 15),
            Container(
              child: SingleChildScrollView(
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: Colors.black12,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45),
                    ),
                    hintText: "Title",
                    prefixIcon: Icon(
                      Icons.title_sharp,
                      color: Colors.amber,
                      size: 35,
                    ),
                  ),
                  onChanged: (value) {
                    thread.title = value;
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              child: SingleChildScrollView(
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: Colors.black12,
                  maxLines: null,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45),
                    ),
                    hintText: "Description",
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      color: Colors.amber,
                      size: 35,
                    ),
                  ),
                  onChanged: (value) {
                    thread.desc = value;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
