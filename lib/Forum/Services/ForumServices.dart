import 'package:cloud_firestore/cloud_firestore.dart';

class CrudMethods {
  Future<void> addData(forumData, dateId) async {
    FirebaseFirestore.instance
        .collection("threads")
        .doc(dateId)
        .set(forumData)
        .catchError((e) {
      print(e);
    });
  }

  getData() async {
    return await FirebaseFirestore.instance
        .collection("threads")
        .orderBy("date", descending: true)
        .snapshots();
  }

  Future<void> addReplyData(replyData, id) async {
    await FirebaseFirestore.instance
        .collection("threads")
        .doc(id)
        .collection("reply")
        .add(replyData);
  }

  getReplyData(id) async {
    return await FirebaseFirestore.instance
        .collection("threads")
        .doc(id)
        .collection("reply")
        .orderBy("date", descending: true)
        .snapshots();
  }
}
