import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;

class NewPost extends StatefulWidget {  
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  String title;
  String content;

  Widget _formContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          decoration: Decorations.postTitleInput,
          validator: (val) => val.isEmpty 
            ? 'Enter a title' 
            : null,
          onChanged: (val) {
            setState(() => title = val);
          },
        ),
        TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: Decorations.postContentInput,
          validator: (val) => val.isEmpty 
            ? 'Enter some content' 
            : null,
          onChanged: (val) {
            setState(() => content = val);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: _formKey,
            child: _formContainer(),
          ),
        )
      ),
      bottomNavigationBar: Card(
        elevation: 4.0,
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              RaisedButton.icon(
                icon: Icon(Icons.cancel, color: Colors.white,),
                label: Text('Discard', style: TextStyle(color: Colors.white)),
                color: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(color: Colors.red)
                ),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton.icon(
                icon: Icon(Icons.done, color: Colors.white,),
                label: Text('Publish', style: TextStyle(color: Colors.white),),
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(color: Colors.green)
                ),
                onPressed: () async {
                  if(_formKey.currentState.validate()) {
                    await DatabaseService().addNewPost(user.uid, title, content);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}