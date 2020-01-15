import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {

  String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'New message...'
              ),
              onChanged: (val) => setState(() => message = val),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.white,),
              color: Constants.chatsColor,
              
              onPressed: () => print('Message Sent!'),
            ),
          ],
        ),
      ),
    );
  }
}