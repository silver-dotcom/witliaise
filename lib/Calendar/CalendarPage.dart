import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:sample/Calendar/Services/CalendarServices.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  bool isTeacher;
  CalendarPage(this.isTeacher);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  EventDataSource? events;
  CalendarServices calendarServices = new CalendarServices();

  Future<void> getData() async {
    var snapshotsValue =
        await FirebaseFirestore.instance.collection("events").get();
    List<EventCS> list = snapshotsValue.docs
        .map((e) => EventCS(
            title: e.data()['title'],
            desc: e.data()['desc'],
            addedBy: e.data()['addedBy'],
            eventType: e.data()['event_type'],
            date: e.data()['date'],
            startTime: e.data()['start_time'],
            endTime: e.data()['end_time']))
        .toList();
    setState(() {
      events = EventDataSource(list);
    });
  }

  @override
  void initState() {
    getData().then((result) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        child: SfCalendar(
          view: CalendarView.month,
          dataSource: events,
          todayHighlightColor: Colors.amber,
          todayTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
          selectionDecoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.3),
            border: Border.all(color: Colors.black26, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            shape: BoxShape.rectangle,
          ),
          monthViewSettings: MonthViewSettings(
            agendaViewHeight: MediaQuery.of(context).size.height * 0.3,
            agendaStyle: AgendaStyle(
              appointmentTextStyle: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            showAgenda: true,
          ),
        ),
      ),
      floatingActionButton: widget.isTeacher == true
          ? Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: FloatingActionButton(
                backgroundColor: Colors.amber,
                onPressed: () {
                  Navigator.pushNamed(context, 'createevent');
                },
                child: Icon(
                  Icons.add,
                  color: Colors.black54,
                  size: 40,
                ),
              ),
            )
          : Container(),
    );
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<EventCS> source) {
    appointments = source;
  }

  TimeOfDay timeConvert(String time) {
    int hour, minute;
    String ampm = time.substring(time.length - 2);
    String result = time.substring(0, time.indexOf(' '));
    if (ampm == 'AM' && int.parse(result.split(":")[1]) != 12) {
      hour = int.parse(result.split(':')[0]);
      if (hour == 12) hour = 0;
      minute = int.parse(result.split(":")[1]);
    } else {
      int.parse(result.split(":")[0]) != 12
          ? hour = int.parse(result.split(":")[0]) + 12
          : hour = 12;
      minute = int.parse(result.split(":")[1]);
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  DateTime join(String date, String time) {
    DateTime dateTime = DateFormat("dd/MM/yyyy").parse(date);
    TimeOfDay timeOfDay = timeConvert(time);
    return new DateTime(dateTime.year, dateTime.month, dateTime.day,
        timeOfDay.hour, timeOfDay.minute);
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  DateTime getStartTime(int index) {
    DateTime start =
        join(appointments![index].date, appointments![index].startTime);
    return start;
  }

  @override
  DateTime getEndTime(int index) {
    DateTime end =
        join(appointments![index].date, appointments![index].endTime);
    return end;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  @override
  Color getColor(int index) {
    return Colors.amber;
  }
}
