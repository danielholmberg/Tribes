import 'package:flutter/material.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class NewPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        elevation: Constants.appBarElevation,
        title: Text('New Post'),
        iconTheme: Theme.of(context).iconTheme,
        textTheme: Theme.of(context).textTheme,
      ),
      body: Container(
        // TODO
      ),
    );
  }
}