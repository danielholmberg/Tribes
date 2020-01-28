import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';

class NewPost extends StatefulWidget {  

  final Tribe tribe;
  NewPost({this.tribe});

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool autofocus;
  FocusNode focusNode;
  
  String title;
  String content;

  @override
  void initState() {
    focusNode = FocusNode();

    Future.delayed(Constants.pageTransition800).then((val) {
      FocusScope.of(context).requestFocus(focusNode);
    });

    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Hero(
      tag: 'NewPostButton',
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: DynamicTheme.of(context).data.backgroundColor,
          leading: IconButton(icon: Icon(Icons.close), 
            color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Constants
                      .profileSettingsBackgroundColor,
                  title: Text(
                      'Are your sure you want to discard changes?'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('No', 
                        style: TextStyle(color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Yes',
                        style: TextStyle(color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Dialog: "Are you sure...?"
                        Navigator.of(context).pop(); // NewPost
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        body: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView(
            children: <Widget>[
              Container(
                color: DynamicTheme.of(context).data.backgroundColor,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              //autofocus: autofocus,
                              focusNode: focusNode,
                              style: DynamicTheme.of(context).data.textTheme.title,
                              cursorColor: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                              decoration: Decorations.postTitleInput.copyWith(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide(
                                    color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor, 
                                    width: 2.0
                                  ),
                                )
                              ),
                              validator: (val) => val.isEmpty 
                                ? 'Enter a title' 
                                : null,
                              onChanged: (val) {
                                setState(() => title = val);
                              },
                            ),
                            SizedBox(height: Constants.defaultSpacing),
                            TextFormField(
                              style: DynamicTheme.of(context).data.textTheme.body1,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              cursorColor: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                              decoration: Decorations.postContentInput.copyWith(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide(
                                    color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor, 
                                    width: 2.0
                                  ),
                                )
                              ),
                              validator: (val) => val.isEmpty 
                                ? 'Enter some content' 
                                : null,
                              onChanged: (val) {
                                setState(() => content = val);
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          color: DynamicTheme.of(context).data.backgroundColor,
          child: ButtonTheme(
            height: 40.0,
            minWidth: MediaQuery.of(context).size.width,
            child: RaisedButton.icon(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8.0),
              ),
              color: Colors.green,
              icon: Icon(Icons.done, color: Constants.buttonIconColor),
              label: Text('Publish'),
              textColor: Colors.white,
              onPressed: () async {
                if(_formKey.currentState.validate()) {
                  await DatabaseService().addNewPost(user.uid, title, content, widget.tribe.id);
                  Navigator.pop(context);
                }
              }
            ),
          ),
        )
      ),
    );
  }
}
