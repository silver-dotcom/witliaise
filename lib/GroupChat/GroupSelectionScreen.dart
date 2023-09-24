import 'package:flutter/material.dart';
import 'package:sample/GroupChat/GroupChatScreen.dart';

class GroupSelectionScreen extends StatefulWidget {
  @override
  _GroupSelectionScreenState createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height),
          padding: EdgeInsets.only(top: 30),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircularButton(text: 'Faculties', groupChatId: 'faculties'),
                  CircularButton(text: 'FYIT', groupChatId: 'fyit'),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircularButton(text: 'SYIT', groupChatId: 'syit'),
                  CircularButton(text: 'TYIT', groupChatId: 'tyit'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircularButton extends StatelessWidget {
  final String text, groupChatId;

  CircularButton({required this.text, required this.groupChatId});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.amber,
          width: 7,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black26,
            width: 5.5,
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            primary: Colors.white,
            shape: CircleBorder(),
            padding: EdgeInsets.all(15),
            fixedSize: Size(110, 110),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 19,
            ),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => GroupChatScreen(groupChatId, true)));
          },
        ),
      ),
    );
  }
}
