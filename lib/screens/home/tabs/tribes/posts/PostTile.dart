import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final Color tribeColor;
  final int index;
  PostTile({this.post, this.tribeColor, this.index});

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  String title;
  String content;

  @override
  Widget build(BuildContext context) {
    _postDetails() {
      return loading ? Loading() : StreamBuilder<User>(
        stream: AuthService().user,
        builder: (context, snapshot) {
          bool isAuthor = snapshot.data.uid == widget.post.author;
          bool isEditing = false;

          return StatefulBuilder(
            builder: (context, setState) { 
              return Scaffold(
                appBar: isAuthor ? 
                AppBar(
                  iconTheme: IconThemeData(
                    color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                  ),
                  centerTitle: true,
                  title: isEditing ? 
                    Text('Editing', style: TextStyle(color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor)) : 
                    Text('Posted: ${DateTime.fromMillisecondsSinceEpoch(widget.post.created)}',
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: Constants.timestampFontSize,
                      ),
                    ),
                  backgroundColor: DynamicTheme.of(context).data.backgroundColor,
                  elevation: 0.0,
                  leading: isEditing ? 
                    IconButton(icon: Icon(Icons.close), 
                      color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
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
                                  style: TextStyle(color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text('Yes',
                                  style: TextStyle(color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop(); // Dialog: "Are you sure...?"
                                  setState(() => isEditing = false);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ) : 
                    IconButton(icon: Icon(Icons.arrow_back), 
                      color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  actions: isEditing ? <Widget>[
                    IconButton(
                      color: DynamicTheme.of(context).data.backgroundColor,
                      icon: Icon(Icons.delete, 
                        color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Constants
                                .profileSettingsBackgroundColor,
                            title: Text(
                                'Are your sure you want to delete this post?'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('No', 
                                  style: TextStyle(color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text('Yes',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  await DatabaseService().deletePost(widget.post.id);
                                  Navigator.of(context).pop(); // Dialog: "Are you sure...?"
                                  Navigator.of(context).pop(); // PostTile
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ] : <Widget> [
                    IconButton(
                      color: DynamicTheme.of(context).data.backgroundColor,
                      icon: Icon(Icons.edit, 
                        color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
                      ),
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                    ),
                  ],
                )
                : AppBar(
                  elevation: 0.0,
                  iconTheme: IconThemeData(
                    color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                  ),
                  backgroundColor: DynamicTheme.of(context).data.backgroundColor,
                  centerTitle: true,
                  title: Text('Posted: ${DateTime.fromMillisecondsSinceEpoch(widget.post.created)}',
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: Constants.timestampFontSize,
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                      color: DynamicTheme.of(context).data.backgroundColor,
                      icon: Icon(Icons.favorite_border, 
                        color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
                      ),
                      onPressed: () async {
                        Fluttertoast.showToast(
                          msg: 'Coming soon!',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      },
                    ),                  ]
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(Icons.account_circle, 
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(width: Constants.smallPadding),
                                    StreamBuilder<UserData>(
                                      stream: DatabaseService().userData(widget.post.author),
                                      builder: (context, snapshot) {
                                        return Text(snapshot.hasData ? snapshot.data.name : '',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontFamily: 'TribesRounded',
                                            fontWeight: FontWeight.normal
                                          ),
                                        );
                                      }
                                    )
                                  ],
                                ),
                                Text('#${widget.index+1}', 
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: Constants.timestampFontSize,
                                  )
                                ),
                              ],
                            ),
                            SizedBox(height: Constants.smallSpacing),
                            Expanded(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Hero(
                                      tag: 'postTitle-${widget.post.id}',
                                      child: TextFormField(
                                        initialValue: widget.post.title,
                                        readOnly: !isEditing,
                                        style: DynamicTheme.of(context).data.textTheme.title,
                                        cursorColor: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                        decoration: InputDecoration(border: InputBorder.none),
                                        validator: (val) => val.isEmpty 
                                          ? 'Enter a title' 
                                          : null,
                                        onChanged: (val) {
                                          setState(() => title = val);
                                        },
                                      ),
                                    ),
                                    Hero(
                                      tag: 'postContent-${widget.post.id}',
                                      child: TextFormField(
                                        initialValue: widget.post.content,
                                        readOnly: !isEditing,
                                        style: DynamicTheme.of(context).data.textTheme.body1,
                                        cursorColor: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        decoration: InputDecoration(border: InputBorder.none),
                                        validator: (val) => val.isEmpty 
                                          ? 'Enter some content' 
                                          : null,
                                        onChanged: (val) {
                                          setState(() => content = val);
                                        },
                                      ),
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
                bottomNavigationBar: isEditing ? Container(
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
                      color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                      icon: Icon(Icons.done,
                        color: Constants.buttonIconColor),
                      label: Text('Save'),
                      textColor: Colors.white,
                      onPressed: () async {
                        if(_formKey.currentState.validate()) {
                          setState(() { 
                            loading = true;
                            isEditing = false; 
                          });
                          await DatabaseService().updatePostData(
                            widget.post.id, 
                            title ?? widget.post.title, 
                            content ?? widget.post.content
                          );

                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text('Post saved'),
                              duration: Duration(milliseconds: 500),
                            )
                          );

                          setState(() => loading = false);  
                        }
                      },
                    ),
                  ),
                ) : SizedBox.shrink(),
              );
            }
          );
        }
      );
    }

    return Card(
      elevation: 4.0,
      color: Constants.postBackgroundColor,
      margin: EdgeInsets.fromLTRB(Constants.largePadding,
          Constants.largePadding, Constants.largePadding, 0.0),
      child: InkWell(
        splashColor: Constants.tribesColor.withAlpha(30),
        onTap: () {
          Navigator.push(context, PageTransition(
            type: PageTransitionType.fade, 
            duration: Duration(milliseconds: Constants.pageTransition600),
            child: _postDetails())
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.account_circle, 
                        color: Colors.blueGrey,
                      ),
                      SizedBox(width: Constants.smallPadding),
                      StreamBuilder<UserData>(
                        stream: DatabaseService().userData(widget.post.author),
                        builder: (context, snapshot) {
                          return Text(snapshot.hasData ? snapshot.data.name : '',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontFamily: 'TribesRounded',
                              fontWeight: FontWeight.normal
                            ),
                          );
                        }
                      )
                    ],
                  ),
                  Text('#${widget.index+1}', 
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: Constants.timestampFontSize,
                    )
                  ),
                ],
              ),
              Hero(
                tag: 'postTitle-${widget.post.id}',
                child: Text(widget.post.title,
                    style: DynamicTheme.of(context).data.textTheme.title),
              ),
              Hero(
                tag: 'postContent-${widget.post.id}',
                child: Text(widget.post.content,
                    style: DynamicTheme.of(context).data.textTheme.body2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
