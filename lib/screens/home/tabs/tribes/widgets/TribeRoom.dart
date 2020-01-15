import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/NewPost.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/Posts.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class TribeRoom extends StatefulWidget {
  @override
  _TribeRoomState createState() => _TribeRoomState();
}

class _TribeRoomState extends State<TribeRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DynamicTheme.of(context).data.primaryColor,
        elevation: 0.0,
        title: Text('Posts',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {print('Clicked on More button');},
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Constants.tribesColor,
        elevation: DynamicTheme.of(context).data.floatingActionButtonTheme.elevation,
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => NewPost())
          );
        },
      ),
      body: Posts(),
    );
  }
}
