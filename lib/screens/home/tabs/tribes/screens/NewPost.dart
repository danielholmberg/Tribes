import 'dart:async';
import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/services/storage.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class NewPost extends StatefulWidget {  

  final Tribe tribe;
  NewPost({this.tribe});

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  
  final _formKey = GlobalKey<FormState>();
  final FocusNode titleFocus = new FocusNode();
  final FocusNode contentFocus = new FocusNode();
  bool loading = false;
  
  String title = '';
  String content = '';

  File _imageFile;
  String _fileURL;
  dynamic _pickImageError;
  String _retrieveDataError;

  @override
  void dispose() {
    titleFocus.dispose();
    contentFocus.dispose();
    super.dispose();
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    try {
      _imageFile = await ImagePicker.pickImage(source: source);
      setState(() {});
    } catch (e) {
      print(e.toString());
      _pickImageError = e;
    }
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Container(
        decoration: BoxDecoration(
          color: (widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.6),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(width: 2.0, color: (widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: (widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor).withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 0),
            ),
          ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          child: Image.file(_imageFile, 
            fit: BoxFit.scaleDown,
            frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
              return child;
            },
          ),
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building NewPost()...');
    print('Current user ${currentUser.toString()}');

    return Hero(
      tag: 'NewPostButton',
      child: Container(
        color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
        child: SafeArea(
          bottom: false,
          child: loading ? Loading() : Scaffold(
            backgroundColor: DynamicTheme.of(context).data.backgroundColor,
            extendBody: true,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: DynamicTheme.of(context).data.backgroundColor,
              leading: IconButton(icon: Icon(Icons.close), 
                color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                onPressed: () {
                  if(title.isNotEmpty || content.isNotEmpty || _imageFile != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                        backgroundColor: Constants
                            .profileSettingsBackgroundColor,
                        title: Text('Are your sure you want to discard changes?',
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
                                color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
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
                                color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                fontFamily: 'TribesRounded',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Dialog: "Are you sure...?"
                              Navigator.of(context).pop(); // NewPost
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add_a_photo),
                  iconSize: Constants.defaultIconSize,
                  color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                  onPressed: () {
                    _onImageButtonPressed(ImageSource.camera, context: context);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add_photo_alternate),
                  iconSize: Constants.defaultIconSize,
                  color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                  onPressed: () {
                    _onImageButtonPressed(ImageSource.gallery, context: context);
                  },
                )
              ],
            ),
            body: Stack(
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
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    TextFormField(
                                      focusNode: titleFocus,
                                      textCapitalization: TextCapitalization.sentences,
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
                                      onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(contentFocus),
                                    ),
                                    SizedBox(height: Constants.defaultSpacing),
                                    TextFormField(
                                      focusNode: contentFocus,
                                      textCapitalization: TextCapitalization.sentences,
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
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Platform.isAndroid
                          ? FutureBuilder<void>(
                              future: retrieveLostData(),
                              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.none:
                                  case ConnectionState.waiting:
                                    return _imageFile != null ? _previewImage() : Text(
                                      'You have not yet picked an image.',
                                      textAlign: TextAlign.center,
                                    );
                                  case ConnectionState.done:
                                    return _previewImage();
                                  default:
                                    if (snapshot.hasError) {
                                      return Text(
                                        'Pick image/video error: ${snapshot.error}}',
                                        textAlign: TextAlign.center,
                                      );
                                    } else {
                                      return Text(
                                        'You have not yet picked an image.',
                                        textAlign: TextAlign.center,
                                      );
                                    }
                                }
                              },
                            )
                          : _previewImage(),
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
                    opacity: (title.isNotEmpty || content.isNotEmpty || _imageFile != null) ? 1.0 : 0.0,
                      child: ButtonTheme(
                      height: 60.0,
                      minWidth: MediaQuery.of(context).size.width,
                      child: RaisedButton.icon(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                        ),
                        color: Colors.green,
                        icon: Icon(Icons.done, color: Constants.buttonIconColor, size: Constants.defaultIconSize),
                        label: Text('Publish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
                        textColor: Colors.white,
                        onPressed: () async {                
                          if(_formKey.currentState.validate()) {
                            setState(() => loading = true);

                            if(_imageFile != null) {
                              _fileURL = await StorageService().uploadFile(_imageFile);
                            }
                            
                            DatabaseService().addNewPost(
                              currentUser.uid, 
                              title, 
                              content, 
                              _fileURL ?? null, 
                              widget.tribe.id
                            );

                            Navigator.pop(context);
                          }
                        }
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

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}
