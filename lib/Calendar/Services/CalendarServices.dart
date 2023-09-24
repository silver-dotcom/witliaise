import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:sample/Calendar/Model/event.dart';

class CalendarServices {
  Future<void> addData(data, title) async {
    FirebaseFirestore.instance
        .collection("events")
        .doc(title)
        .set(data)
        .catchError((e) {
      print(e);
    });
  }

  // Future<List<EventCS>> getData() async {
  //   var snapshotsValue =
  //       await FirebaseFirestore.instance.collection("events").get();
  //   List<EventCS> list = snapshotsValue.docs
  //       .map((e) => EventCS(
  //           title: e.data()['title'],
  //           desc: e.data()['desc'],
  //           addedBy: e.data()['addedBy'],
  //           eventType: e.data()['event_type'],
  //           date: e.data()['date'],
  //           startTime: e.data()['start_time'],
  //           endTime: e.data()['end_time']))
  //       .toList();
  //   return list;
  // }
}

class EventCS {
  String? title, desc, addedBy, eventType, date, startTime, endTime;

  EventCS(
      {this.title,
      this.desc,
      this.addedBy,
      this.eventType,
      this.date,
      this.startTime,
      this.endTime});
}
