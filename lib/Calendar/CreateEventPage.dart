import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sample/Calendar/Model/event.dart';
import 'package:sample/Calendar/Services/CalendarServices.dart';
import 'package:sample/Login/LoginPage.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  late String addedBy;
  final now = DateTime.now();

  Event event = Event("", "", "", "", "");
  CalendarServices calendarServices = new CalendarServices();
  DateTime? pickedDate;
  TimeOfDay? pickedStartTime, pickedEndTime;

  addEvent() async {
    addedBy = FirebaseAuth.instance.currentUser!.displayName!;
    event.addedBy = addedBy;
    Map<String, dynamic> eventMap = {
      "addedBy": event.addedBy,
      "title": event.title,
      "date": event.date,
      "start_time": event.startTime,
      "end_time": event.endTime
    };
    calendarServices.addData(eventMap, event.title).then((result) {
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
              Icons.add_box_outlined,
              size: 30,
            ),
            onPressed: () {
              if (event.title == "")
                ScaffoldSnackbar.of(context)
                    .show('Please enter the title of the event!');
              else if (event.date == "")
                ScaffoldSnackbar.of(context).show('Please select a date!');
              else if (event.startTime == "")
                ScaffoldSnackbar.of(context)
                    .show('Please select the start time of the event!');
              else if (event.endTime == "")
                ScaffoldSnackbar.of(context)
                    .show('Please select the end time of the event!');
              else
                addEvent();
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              child: SingleChildScrollView(
                child: TextField(
                  autofocus: mounted,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: Colors.black12,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45),
                    ),
                    hintText: "Event Title",
                    prefixIcon: Icon(
                      Icons.event_outlined,
                      color: Colors.amber,
                      size: 35,
                    ),
                  ),
                  onChanged: (value) {
                    event.title = value;
                  },
                ),
              ),
            ),
            SizedBox(height: 15),
            TextButton.icon(
              icon: Icon(
                Icons.date_range,
                color: Colors.amber,
                size: 35,
              ),
              style: TextButton.styleFrom(textStyle: TextStyle(fontSize: 18)),
              onPressed: () async {
                final initialDate = DateTime.now();
                final newDate = await showDatePicker(
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.amber,
                          onPrimary: Colors.black54,
                          onSurface: Colors.black,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                  context: context,
                  initialDate: pickedDate ?? initialDate,
                  firstDate: DateTime(DateTime.now().year - 5),
                  lastDate: DateTime(DateTime.now().year + 5),
                );
                if (newDate == null) return;
                setState(() {
                  pickedDate = newDate;
                  event.date =
                      DateFormat('dd/MM/yyyy').format(pickedDate!).toString();
                });
              },
              label: pickedDate == null
                  ? Text(
                      "Pick A Date",
                      style: TextStyle(color: Colors.black54),
                    )
                  : Text(
                      DateFormat('dd/MM/yyyy').format(pickedDate!),
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
            ),
            SizedBox(height: 15),
            SizedBox(height: 1.3, child: Container(color: Colors.black26)),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 40,
              color: Colors.transparent,
              child: AspectRatio(
                aspectRatio: 5,
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.timer_rounded,
                          size: 28,
                          color: Colors.amber,
                        ),
                        style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: 18)),
                        onPressed: () async {
                          final initialTime = TimeOfDay(hour: 12, minute: 0);
                          final newTime = await showTimePicker(
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.amber,
                                    onPrimary: Colors.black54,
                                    onSurface: Colors.black,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      primary: Colors.black,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                            context: context,
                            initialTime: pickedStartTime ?? initialTime,
                          );
                          if (newTime == null) return;
                          setState(() {
                            pickedStartTime = newTime;
                            event.startTime = DateFormat("h:mm a")
                                .format(DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    pickedStartTime!.hour,
                                    pickedStartTime!.minute))
                                .toString();
                          });
                        },
                        label: pickedStartTime == null
                            ? Text(
                                "Start Time",
                                style: TextStyle(color: Colors.black54),
                              )
                            : Text(
                                DateFormat.jm().format(DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    pickedStartTime!.hour,
                                    pickedStartTime!.minute)),
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 22,
                                ),
                              ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                          width: 1.3, child: Container(color: Colors.black26)),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.timer_rounded,
                          size: 28,
                          color: Colors.amber,
                        ),
                        style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: 18)),
                        onPressed: () async {
                          final initialTime = TimeOfDay(hour: 12, minute: 0);
                          final newTime = await showTimePicker(
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.amber,
                                    onPrimary: Colors.black54,
                                    onSurface: Colors.black,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      primary: Colors.black,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                            context: context,
                            initialTime: pickedEndTime ?? initialTime,
                          );
                          if (newTime == null) return;
                          setState(() {
                            pickedEndTime = newTime;
                            event.endTime = DateFormat("h:mm a")
                                .format(DateTime(now.year, now.month, now.day,
                                    pickedEndTime!.hour, pickedEndTime!.minute))
                                .toString();
                          });
                        },
                        label: pickedEndTime == null
                            ? Text(
                                "End Time",
                                style: TextStyle(color: Colors.black54),
                              )
                            : Text(
                                DateFormat.jm().format(DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    pickedEndTime!.hour,
                                    pickedEndTime!.minute)),
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 22,
                                ),
                              ),
                      ),
                    ),
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
