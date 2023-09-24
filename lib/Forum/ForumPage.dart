import 'package:flutter/cupertino.dart';
import 'package:sample/Forum/Models/thread.dart';
import 'package:sample/Forum/ThreadPage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:sample/Forum/Services/ForumServices.dart';
import 'package:flutter/material.dart';

class ForumPage extends StatefulWidget {
  ForumPage({Key? key}) : super(key: key);

  @override
  _ForumPageState createState() => new _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  CrudMethods crudMethods = new CrudMethods();
  Stream? forumsStream;

  Widget ForumsList() {
    return Container(
      child: forumsStream != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: StreamBuilder(
                    stream: forumsStream,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.data == null)
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.amber,
                          ),
                        );
                      return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: snapshot.data.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ForumTile(
                                title:
                                    snapshot.data.docs[index].data()['title'],
                                description:
                                    snapshot.data.docs[index].data()['desc'],
                                postedBy: snapshot.data.docs[index]
                                    .data()['postedBy'],
                                date: snapshot.data.docs[index].data()["date"]);
                          });
                    },
                  ),
                ),
                SizedBox(height: 90),
              ],
            )
          : Container(
              alignment: Alignment.center,
              child: Text("No Forums Created Yet!"),
            ),
    );
  }

  @override
  void initState() {
    crudMethods.getData().then((result) {
      setState(() {
        forumsStream = result;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ForumsList(),
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: FloatingActionButton(
          backgroundColor: Colors.amber,
          onPressed: () {
            Navigator.pushNamed(context, 'createthread');
          },
          child: Icon(
            Icons.add,
            color: Colors.black54,
            size: 40,
          ),
        ),
      ),
    );
  }
}

class ForumTile extends StatelessWidget {
  String title, description, postedBy;
  int date;
  Thread thread = Thread(0, "", "", "");
  ForumTile(
      {required this.title,
      required this.description,
      required this.postedBy,
      required this.date});

  @override
  Widget build(BuildContext context) {
    thread.title = title;
    thread.desc = description;
    thread.date = date;
    thread.postedBy = postedBy;

    return Container(
      margin: EdgeInsets.only(top: 16),
      height: 90,
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ThreadPage(thread)));
            },
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6)),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6.0),
                          topLeft: Radius.circular(6.0))),
                  child: Center(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5, top: 4),
                  child: Container(
                    height: 20,
                    child: Text(
                      description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5, right: 5, top: 15),
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
                              postedBy,
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              timeago.format(
                                  DateTime.fromMillisecondsSinceEpoch(date)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
