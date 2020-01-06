import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/screens/home/widgets/NewPost.dart';
import 'package:tribes/screens/home/widgets/Posts.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Post>>.value(
      value: DatabaseService().posts,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).accentColor,
          elevation: Constants.appBarElevation,
          title: Text('Home'),
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('Sign out'),
              onPressed: () async {
                await _auth.signOut();
              },
            )
          ],
          iconTheme: Theme.of(context).iconTheme,
          textTheme: Theme.of(context).textTheme,
        ),
        body: Posts(),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.edit),
          backgroundColor: Theme.of(context).accentColor,
          elevation: Constants.buttonElevation,
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => NewPost())
            );
          },
        ),
      ),
    );
  }
}