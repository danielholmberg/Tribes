import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final Color tribeColor;
  PostTile({this.post, this.tribeColor});

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {

  @override
  Widget build(BuildContext context) {
    _postDetails() {
      return StreamBuilder<User>(
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
                                child: Text('No'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                child: Text('Yes'),
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
                    FlatButton.icon(
                      color: DynamicTheme.of(context).data.backgroundColor,
                      icon: Icon(Icons.delete, 
                        color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
                      ),
                      label: Text('Delete', 
                        style: TextStyle(color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor)
                      ),
                      onPressed: () async {
                        await DatabaseService().deletePost(widget.post.id);
                        Navigator.of(context).pop();
                      },
                    ),
                  ] : <Widget> [
                    FlatButton.icon(
                      color: DynamicTheme.of(context).data.backgroundColor,
                      icon: Icon(Icons.edit, 
                        color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
                      ),
                      label: Text('Edit', 
                        style: TextStyle(color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor)
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
                            StreamBuilder<UserData>(
                              stream: DatabaseService().userData(widget.post.author),
                              builder: (context, snapshot) {
                                return RichText(
                                  text: TextSpan(
                                    text: 'Posted by ',
                                    style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontFamily: 'TribesRounded',
                                        fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: snapshot.hasData ? snapshot.data.name : '',
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.normal
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            ),
                            SizedBox(height: Constants.smallSpacing),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Hero(
                                    tag: 'postTitle-${widget.post.id}',
                                    child: Text(widget.post.title,
                                        style: DynamicTheme.of(context).data.textTheme.title),
                                  ),
                                  Hero(
                                    tag: 'postContent-${widget.post.id}',
                                    child: Text(widget.post.content,
                                        style: DynamicTheme.of(context).data.textTheme.body1),
                                  )
                                ],
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
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                        });
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
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => _postDetails()));
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
