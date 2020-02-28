import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/DiscardChangesDialog.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class PostRoom extends StatefulWidget {
  final Color tribeColor;
  final Post post;
  PostRoom(this.post, this.tribeColor);

  @override
  _PostRoomState createState() => _PostRoomState();
}

class _PostRoomState extends State<PostRoom> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final FocusNode titleFocus = new FocusNode();
  final FocusNode contentFocus = new FocusNode();
  bool loading = false;
  bool edited = false;

  String title;
  String content;
  String originalTitle;
  String originalContent;

  @override
  void dispose() {
    titleFocus.dispose();
    contentFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    originalTitle = widget.post.title;
    originalContent = widget.post.content;
    title = originalTitle;
    content = originalContent;

    Future.delayed(Duration(milliseconds: 650)).then((val) {
      FocusScope.of(context).requestFocus(titleFocus);
    });
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building PostRoom()...');
    print('Current user ${currentUser.toString()}');

    _showDiscardDialog() {
      return showDialog(
        context: context,
        builder: (context) => DiscardChangesDialog(color: widget.tribeColor)
      );
    }

    return WillPopScope(
      onWillPop: () => edited ? _showDiscardDialog() : Future(() => true),
      child: Container(
        color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
        child: SafeArea(
          bottom: false,
          child: loading ? Loading() : Scaffold(
            key: _scaffoldKey,
            backgroundColor: DynamicTheme.of(context).data.backgroundColor,
            appBar: AppBar(
              backgroundColor: DynamicTheme.of(context).data.backgroundColor,
              elevation: 0.0,
              iconTheme: IconThemeData(
                color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
              ),
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text('Editing', 
                    style: TextStyle(
                      fontFamily: 'TribesRounded',
                      fontWeight: FontWeight.bold,
                      color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
                    ),
                  ),
                  SizedBox(width: Constants.defaultPadding),
                  Visibility(
                    visible: edited,
                    child: Text('| edited', 
                      style: TextStyle(
                        fontFamily: 'TribesRounded',
                        fontStyle: FontStyle.normal,
                        fontSize: 12,
                        color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
                      ),
                    ),
                  ),
                ],
              ),
              leading: IconButton(icon: Icon(Platform.isIOS ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.arrowLeft), 
                color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                onPressed: () {
                  edited ? _showDiscardDialog() : Navigator.of(context).pop();
                },
              ),
              actions: <Widget>[
                IconButton(
                  splashColor: Colors.transparent,
                  color: DynamicTheme.of(context).data.backgroundColor,
                  icon: CustomAwesomeIcon(
                    icon: FontAwesomeIcons.solidTrashAlt, 
                    color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                        backgroundColor: Constants
                            .profileSettingsBackgroundColor,
                        title: Text('Are your sure you want to delete this post?',
                          style: TextStyle(
                            fontFamily: 'TribesRounded',
                            fontWeight: Constants.defaultDialogTitleFontWeight,
                            fontSize: Constants.defaultDialogTitleFontSize,
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('No', 
                              style: TextStyle(
                                color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                fontFamily: 'TribesRounded',
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('Yes',
                              style: TextStyle(
                                color: Colors.red,
                                fontFamily: 'TribesRounded',
                                fontWeight: FontWeight.bold,
                              ),
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
              ]
            ),
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: CustomScrollBehavior(),
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 76.0),
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                TextFormField(
                                  focusNode: titleFocus,
                                  initialValue: title ?? widget.post.title,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: DynamicTheme.of(context).data.textTheme.title,
                                  cursorColor: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                  decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(0)),
                                  validator: (val) => val.isEmpty 
                                    ? 'Enter a title' 
                                    : null,
                                  onChanged: (val) {
                                    setState(() {
                                      title = val;
                                      edited = originalTitle != val || originalContent != content;
                                    });
                                  },
                                  onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(contentFocus),
                                ),
                                TextFormField(
                                  focusNode: contentFocus,
                                  initialValue: content ?? widget.post.content,
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
                                    setState((){
                                      content = val;
                                      edited = originalContent != val || originalTitle != title;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        widget.post.fileURL.isEmpty 
                        ? SizedBox.shrink() 
                        : Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.post.fileURL,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.6),
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                border: Border.all(width: 2.0, color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.4)),
                                boxShadow: [
                                  BoxShadow(
                                    color: (widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: Offset(0, 0),
                                  ),
                                ]
                              ),
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
                            errorWidget: (context, url, error) => Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: edited ? 1.0 : 0.0,
                    child: ButtonTheme(
                      height: 60.0,
                      minWidth: MediaQuery.of(context).size.width,
                      child: RaisedButton.icon(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                        ),
                        color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                        icon: CustomAwesomeIcon(icon: FontAwesomeIcons.check, size: Constants.smallIconSize),
                        label: Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
                        textColor: Colors.white,
                        onPressed: edited ? () {
                          if(_formKey.currentState.validate()) {
                            setState(() { 
                              loading = true;
                            });

                            DatabaseService().updatePostData(
                              widget.post.id, 
                              title ?? widget.post.title, 
                              content ?? widget.post.content
                            );

                            _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                                content: Text('Post saved', 
                                  style: TextStyle(
                                    fontFamily: 'TribesRounded'
                                  ),
                                ),
                                duration: Duration(milliseconds: 500),
                              )
                            );

                            FocusScope.of(context).unfocus();

                            setState(() {
                              loading = false;
                              edited = false;
                              originalTitle = title;
                              originalContent = content;
                            });
                          }
                        } : null,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
