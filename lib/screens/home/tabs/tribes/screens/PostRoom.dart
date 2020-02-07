import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/utils.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/Loading.dart';
import 'package:geocoder/geocoder.dart';

class PostRoom extends StatefulWidget {
  final Color tribeColor;
  final Post post;
  final int index;
  PostRoom({this.tribeColor, this.post, this.index});

  @override
  _PostRoomState createState() => _PostRoomState();
}

class _PostRoomState extends State<PostRoom> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;
  bool loading = false;
  FocusNode focusNode = FocusNode();
  Coordinates coordinates;
  Future<List<Address>> addressFuture;

  String title;
  String content;

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if((widget.post.lat != 0 && widget.post.lng != 0)) {
      coordinates = Coordinates(widget.post.lat, widget.post.lng);
      addressFuture = Geocoder.local.findAddressesFromCoordinates(coordinates);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building PostRoom()...');
    print('Current user ${currentUser.toString()}');
    bool isAuthor = currentUser.uid == widget.post.author;

    return Scaffold(
      key: _scaffoldKey ,
      appBar: isAuthor ? 
      AppBar(
        iconTheme: IconThemeData(
          color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
        ),
        centerTitle: true,
        title: isEditing ? 
          Text('Editing', style: TextStyle(color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor)) : 
          postedDateTime(widget.post.created),
        backgroundColor: DynamicTheme.of(context).data.backgroundColor,
        elevation: 0.0,
        leading: isEditing ? 
          IconButton(icon: Icon(Icons.close), 
            color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
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
            splashColor: Colors.transparent,
            color: DynamicTheme.of(context).data.backgroundColor,
            icon: Icon(Icons.delete, 
              color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
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
                        await DatabaseService().deletePost(widget.post);
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
            splashColor: Colors.transparent,
            color: DynamicTheme.of(context).data.backgroundColor,
            icon: Icon(Icons.edit, 
              color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
            ),
            onPressed: () {
              FocusScope.of(context).requestFocus(focusNode);
              setState(() {
                isEditing = true;
              });
            },
          ),
          likeButton(
            currentUser, 
            widget.post.id, 
            (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor)
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
        title: postedDateTime(widget.post.created),
        actions: <Widget>[
          likeButton(
            currentUser, 
            widget.post.id, 
            (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor)
          ),      
        ]
      ),
      body: Container(
        color: DynamicTheme.of(context).data.backgroundColor,
        child: loading ? Loading()
        : Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: ListView(
                padding: EdgeInsets.only(bottom: isEditing ? 64.0 : 16.0),
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.account_circle, 
                                  color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                  size: Constants.mediumIconSize,
                                ),
                                SizedBox(width: Constants.defaultPadding),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(currentUser.name,
                                      style: TextStyle(
                                        color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                        fontFamily: 'TribesRounded',
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    FutureBuilder(
                                      future: addressFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          var addresses = snapshot.data;
                                          var first = addresses.first;
                                          var location = '${first.addressLine}';
                                          print('lat ${widget.post.lat}, lng ${widget.post.lng}');
                                          print('location: $location');
                                          return Text(location,
                                            style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontFamily: 'TribesRounded',
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          print('Error getting address from coordinates: ${snapshot.error}');
                                          return SizedBox.shrink();
                                        } else {
                                          return SizedBox.shrink();
                                        }
                                        
                                      }
                                    ),
                                    
                                    ],
                                )
                              ],
                            ),
                            widget.index != null ? Text('#${widget.index+1}', 
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: Constants.timestampFontSize,
                              )
                            ) : SizedBox.shrink(),
                          ],
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Hero(
                                tag: 'postTitle-${widget.post.id}',
                                child: TextFormField(
                                  focusNode: focusNode,
                                  initialValue: title ?? widget.post.title,
                                  readOnly: !isEditing,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: DynamicTheme.of(context).data.textTheme.title,
                                  cursorColor: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                  decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(0)),
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
                                  initialValue: content ?? widget.post.content,
                                  readOnly: !isEditing,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: DynamicTheme.of(context).data.textTheme.body1,
                                  cursorColor: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(0)),
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
                      ],
                    ),
                  ),
                  widget.post.fileURL.isEmpty 
                  ? SizedBox.shrink() 
                  : Hero(
                    tag: 'postImage-${widget.post.id}',
                    child: CachedNetworkImage(
                      imageUrl: widget.post.fileURL,
                      imageBuilder: (context, imageProvider) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          child: Image(
                            image: imageProvider, 
                            fit: BoxFit.scaleDown,
                            frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
                              return child;
                            },
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Loading(),
                      errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
                    ),
                  ),
                ],
              ),
            ),
            isEditing ? Positioned(
              bottom: 0.0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                color: Colors.transparent,
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
                        ).then((val) {
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text('Post saved'),
                              duration: Duration(milliseconds: 500),
                            )
                          );

                          setState(() => loading = false);  
                        });
                      }
                    },
                  ),
                ),
              ),
            ) : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
