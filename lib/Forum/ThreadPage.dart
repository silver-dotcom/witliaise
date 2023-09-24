import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sample/Forum/Models/reply.dart';
import 'package:sample/Forum/Models/thread.dart';
import 'package:sample/Forum/Services/ForumServices.dart';

class ThreadPage extends StatefulWidget {
  Thread thread;

  ThreadPage(this.thread);

  @override
  _ThreadPageState createState() => new _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  final TextEditingController _reply = TextEditingController();
  CrudMethods crudMethods = new CrudMethods();
  Reply reply = Reply(0, "", "");
  Stream? repliesStream;
  String? id;

  @override
  void initState() {
    id = widget.thread.date.toString();
    crudMethods.getReplyData(id).then((result) {
      setState(() {
        repliesStream = result;
      });
    });
    super.initState();
  }

  uploadReply() async {
    String postedBy = FirebaseAuth.instance.currentUser!.displayName!;
    reply.postedBy = postedBy;
    reply.date = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> replyMap = {
      "postedBy": reply.postedBy,
      "desc": reply.desc,
      "date": reply.date
    };
    crudMethods.addReplyData(replyMap, id);
    _reply.clear();
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
      ),
      // body: Container(
      //   height: MediaQuery.of(context).size.height,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.thread.postedBy,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat.yMMMMd().add_jms().format(
                      DateTime.fromMillisecondsSinceEpoch(widget.thread.date)),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 7),
              Container(
                constraints: BoxConstraints(
                  maxHeight: double.infinity,
                ),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(6)),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 35,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(6.0),
                              topLeft: Radius.circular(6.0))),
                      child: Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          widget.thread.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 10),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          widget.thread.desc,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                // height: double.infinity,
                height: MediaQuery.of(context).size.height * 0.65,
                // height: MediaQuery.of(context).size.height / 1.27,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder(
                  stream: repliesStream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          itemCount: snapshot.data.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ReplyTile(
                                desc: snapshot.data.docs[index].data()['desc'],
                                postedBy: snapshot.data.docs[index]
                                    .data()['postedBy'],
                                date: snapshot.data.docs[index].data()["date"]);
                          });
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Container(
                  child: SingleChildScrollView(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textAlign: TextAlign.left,
                      controller: _reply,
                      onChanged: (value) {
                        reply.desc = value;
                      },
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 17),
                        suffixIcon: IconButton(
                          color: Colors.black45,
                          onPressed: uploadReply,
                          icon: Icon(Icons.send),
                        ),
                        hintText: "Type a comment here",
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.circular(5),
                        // ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ReplyTile extends StatelessWidget {
  String desc, postedBy;
  int date;
  Reply reply = Reply(0, "", "");
  ReplyTile({required this.desc, required this.postedBy, required this.date});

  @override
  Widget build(BuildContext context) {
    reply.desc = desc;
    reply.postedBy = postedBy;
    reply.date = date;

    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5, top: 5),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 20,
                color: Colors.transparent,
                child: AspectRatio(
                  aspectRatio: 5.5,
                  child: Stack(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          reply.postedBy,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          DateFormat.yMMMMd().add_jm().format(
                              DateTime.fromMillisecondsSinceEpoch(reply.date)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(
                maxHeight: double.infinity,
              ),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 10),
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      child: Text(
                        reply.desc,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
