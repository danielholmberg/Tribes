import 'dart:async';
import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/services/storage.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as Path;

class NewPost extends StatefulWidget {  

  final Tribe tribe;
  NewPost({this.tribe});

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool autofocus;
  FocusNode focusNode;
  
  String title;
  String content;

  File _imageFile;
  String _fileURL;
  dynamic _pickImageError;
  bool isVideo = false;
  VideoPlayerController _controller;
  String _retrieveDataError;

  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  @override
  void initState() {
    focusNode = FocusNode();

    Future.delayed(Duration(milliseconds: 850)).then((val) {
      FocusScope.of(context).requestFocus(focusNode);
    });

    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.pause();
    }
    super.deactivate();
  }

  Future<void> _playVideo(File file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      _controller = VideoPlayerController.file(file);
      await _controller.setVolume(1.0);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      setState(() {});
    }
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    if (_controller != null) {
      await _controller.setVolume(0.0);
    }
    if (isVideo) {
      final File file = await ImagePicker.pickVideo(source: source);
      await _playVideo(file);
    } else {
      try {
        _imageFile = await ImagePicker.pickImage(source: source);
        setState(() {});
      } catch (e) {
        _pickImageError = e;
      }
    }
  }

  Future<void> _disposeVideoController() async {
    if (_controller != null) {
      await _controller.dispose();
      _controller = null;
    }
  }

  Widget _previewVideo() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Container(
      width: 200,
      height: 200,
      color: DynamicTheme.of(context).data.backgroundColor,
      padding: const EdgeInsets.all(8.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      return Image.file(_imageFile, 
        width: 200, 
        height: 200,
        frameBuilder: (BuildContext context, Widget child, int frame, bool wasSynchronouslyLoaded) {
          return Container(
            color: DynamicTheme.of(context).data.backgroundColor,
            padding: EdgeInsets.all(16),
            child: child,
          );
        },
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
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } else {
        isVideo = false;
        setState(() {
          _imageFile = response.file;
        });
      }
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Hero(
      tag: 'NewPostButton',
      child: loading ? Container(
          color: DynamicTheme.of(context).data.backgroundColor,
          child: Center(child: CircularProgressIndicator())
        ) : Scaffold(
        extendBody: true,
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_a_photo),
              iconSize: Constants.defaultIconSize,
              color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.camera, context: context);
              },
            ),
            IconButton(
              icon: Icon(Icons.add_photo_alternate),
              iconSize: Constants.defaultIconSize,
              color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.gallery, context: context);
              },
            ),
            IconButton(
              icon: Icon(Icons.video_call),
              iconSize: Constants.defaultIconSize,
              color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.camera);
              },
            ),
            IconButton(
              icon: Icon(Icons.video_library),
              iconSize: Constants.defaultIconSize,
              color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.gallery);
              },
            ),
          ],
        ),
        body: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView(
            children: <Widget>[
              Container(
                color: DynamicTheme.of(context).data.backgroundColor,
                child: Platform.isAndroid
                ? FutureBuilder<void>(
                    future: retrieveLostData(),
                    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return Text(
                            'You have not yet picked an image.',
                            textAlign: TextAlign.center,
                          );
                        case ConnectionState.done:
                          return isVideo ? _previewVideo() : _previewImage();
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
                : (isVideo ? _previewVideo() : _previewImage()),
              ),
              Container(
                color: DynamicTheme.of(context).data.backgroundColor,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
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
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                  setState(() => loading = true);

                  if(_imageFile != null) {
                    _fileURL = await uploadFile();
                  }
                  await DatabaseService().addNewPost(
                    user.uid, 
                    title, 
                    content, 
                    _fileURL ?? null, 
                    widget.tribe.id);
                  Navigator.pop(context);
                }
              }
            ),
          ),
        )
      ),
    );
  }

  Future<String> uploadFile() async {    
    StorageReference storageReference = StorageService().postImagesRoot.child('${Path.basename(_imageFile.path)}');    
    StorageUploadTask uploadTask = storageReference.putFile(_imageFile);    
    await uploadTask.onComplete;    
    print('File Uploaded');    
    return await storageReference.getDownloadURL();    
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

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.initialized) {
      initialized = controller.value.initialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
}
