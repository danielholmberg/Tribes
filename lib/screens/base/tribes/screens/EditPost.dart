import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/tribes/widgets/CustomImage.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/services/storage.dart';
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomButton.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/DiscardChangesDialog.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class EditPost extends StatefulWidget {
  final Post post;
  final Color tribeColor;
  EditPost({@required this.post, this.tribeColor = Constants.primaryColor});

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final FocusNode titleFocus = new FocusNode();
  final FocusNode contentFocus = new FocusNode();
  bool loading = false;
  bool photoButtonIsDisabled;

  String title;
  String content;
  List<String> oldImages = [];
  String originalTitle;
  String originalContent;
  List<String> originalImages = [];

  List<Asset> newImages = [];

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
    originalImages = new List<String>.from(widget.post.images);
    title = originalTitle;
    content = originalContent;
    oldImages = new List<String>.from(originalImages);
    photoButtonIsDisabled = oldImages.length == 5;

    Future.delayed(Duration(milliseconds: 650)).then((val) {
      FocusScope.of(context).requestFocus(titleFocus);
    });
    
    super.initState();
  }

  Future<void> _loadAssets() async {
    List<Asset> resultList;

    try {
      int remainingImages = 5 - (oldImages.length + newImages.length);
      String title = remainingImages == 5 ? 
      "Add images" : "Add $remainingImages more image${remainingImages > 1 ? 's' : ''}";

      resultList = await MultiImagePicker.pickImages(
        maxImages: remainingImages,
        enableCamera: true,
        materialOptions: MaterialOptions(
          actionBarTitle: title,
          allViewTitle: title,
          actionBarColor: "#ed217c",  // TO-DO: Change
          actionBarTitleColor: "#ffffff",  // TO-DO: Change
          lightStatusBar: false,
          statusBarColor: '#ed217c',  // TO-DO: Change
          startInAllView: true,
          selectCircleStrokeColor: "#ed217c", // TO-DO: Change
          selectionLimitReachedText: "You can't add any more.",
      ),
      cupertinoOptions: CupertinoOptions(
        selectionFillColor: "#ed217c",  // TO-DO: Change
        selectionTextColor: "#ffffff",  // TO-DO: Change
        selectionCharacter: "✓",
      ),
    );
    } on PermissionDeniedException catch (e) {
      // User has denied image permission
      print(e.toString());
    } on PermissionPermanentlyDeniedExeption catch (e) {
      // User has denied image permission permanently
      print(e.toString());
    } on NoImagesSelectedException catch (e) {
      // User pressed cancel
      print(e.toString());
    } on Exception catch (e) {
      // Generic error
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if(resultList.length > 0) {
      setState(() {
        newImages += resultList;
        photoButtonIsDisabled = (oldImages.length + newImages.length) == 5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building EditPost()...');
    print('Current user ${currentUser.toString()}');

    print('originalImages: ${originalImages.length}');
    print('oldImages: ${oldImages.length}');

    bool edited = originalTitle != title || originalContent != content || newImages.length > 0 || (originalImages.length != oldImages.length);
    bool step1Completed = title.trim().isNotEmpty;
    bool step2Completed = content.trim().isNotEmpty;
    bool step3Completed = oldImages.length + newImages.length > 0;

    _showDiscardDialog() {
      return showDialog(
        context: context,
        builder: (context) => DiscardChangesDialog(color: widget.tribeColor)
      );
    }

    _buildAppBar() {
      return AppBar(
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
        leading: IconButton(icon: Icon(FontAwesomeIcons.times), 
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
          SizedBox(width: 4.0)
        ]
      );
    }

    _buildNewImageIcon() {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomAwesomeIcon(
            icon: FontAwesomeIcons.camera, 
            size: 30,
            color: widget.tribeColor.withOpacity(photoButtonIsDisabled ? 0.4 : 1.0),
          ), 
          Positioned(
            left: 30,
            top: 30,
            child: Container(
              child: CustomAwesomeIcon(
                icon: FontAwesomeIcons.plus, 
                size: 14, 
                color: widget.tribeColor.withOpacity(photoButtonIsDisabled ? 0.4 : 1.0),
                strokeWidth: 2.0,
              ),
            ),
          ),
        ],
      );
    }

    List<Widget> _buildImages(int length, bool isNewImage) {
      return List.generate(length, (index) {
        int _imageNumber = index + 1 + (isNewImage ? oldImages.length : 0);

        return PhotoView.customChild(
            backgroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 2,
                  offset: Offset(0, 0),
                ),
              ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                children: <Widget>[
                  isNewImage ? AssetThumb(
                    asset: newImages[index],
                    width: 300,
                    height: 300,
                  ) : CustomImage(
                    imageURL: oldImages[index],
                    color: widget.tribeColor,
                    width: 300,
                    height: 300,
                    margin: EdgeInsets.zero,
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 1.0),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      child: GestureDetector(
                        child: CustomAwesomeIcon(icon: FontAwesomeIcons.timesCircle),
                        onTap: () {
                          isNewImage ? newImages.removeAt(index) : oldImages.removeAt(index);
                          setState(() {
                            photoButtonIsDisabled = (oldImages.length + newImages.length) == 5;
                          });
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Visibility(
                      visible: oldImages.length + newImages.length > 1,
                      child: Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: widget.tribeColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: Center(
                          child: Text(
                            '$_imageNumber',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              fontFamily: 'TribesRounded',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
      });
    }

    _buildGridView() {
      List<Widget> children = [];

      if(oldImages.length > 0) {
        children += _buildImages(oldImages.length, false);
      }

      if(newImages.length > 0) {
        children += _buildImages(newImages.length, true);
      }

      return GridView.count(
        crossAxisCount: 3,
        padding: Constants.imageGridViewPadding,
        shrinkWrap: true,
        crossAxisSpacing: Constants.imageGridViewCrossAxisSpacing,
        mainAxisSpacing: Constants.imageGridViewMainAxisSpacing,
        children: <Widget>[
          GestureDetector(
            onTap: photoButtonIsDisabled ? null : () async => await _loadAssets(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  width: 2.0,
                  color: widget.tribeColor.withOpacity(photoButtonIsDisabled ? 0.4 : 1.0),
                ),
              ),
              child: _buildNewImageIcon(),
            ),
          ),
        ] + children,
      );
    }

    _buildStepIndicator(int number, {bool completed = false}) {
      return GestureDetector(
        onTap: () async {
          switch (number) {
            case 1:
              titleFocus.requestFocus();
              break;
            case 2:
              contentFocus.requestFocus();
              break;
            case 3:
              if(!photoButtonIsDisabled) await _loadAssets();
              break;
            default: return;
          }
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: completed ? widget.tribeColor.withOpacity(0.6) : Colors.transparent,
            borderRadius: BorderRadius.circular(1000),
            border: Border.all(color: widget.tribeColor, width: 2.0)
          ),
          child: Center(
            child: completed ? CustomAwesomeIcon(
              icon: FontAwesomeIcons.check, 
              size: 10, 
              color: Colors.white) 
            : Text(
              '$number',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.tribeColor,
                fontFamily: 'TribesRounded',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    _buildSaveButton() {
      return Visibility(
        visible: (step1Completed && step2Completed && step3Completed) && edited,
        child: CustomButton(
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(16.0),
          color: widget.tribeColor,
          icon: FontAwesomeIcons.check,
          label: Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
          labelColor: Colors.white,
          onPressed: edited ? () async {
            if(_formKey.currentState.validate()) {
              setState(() => loading = true);
              List<String> imageURLs = [];

              await Future.forEach(newImages, (image) async {
                String imageURL = await StorageService().uploadPostImage(image);
                imageURLs.add(imageURL);
              });

              setState(() {
                oldImages += imageURLs;
              });

              DatabaseService().updatePostData(
                widget.post.id, 
                title ?? widget.post.title, 
                content ?? widget.post.content,
                oldImages ?? widget.post.images,
              );

              if(newImages.length == 0) {
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
              }

              FocusScope.of(context).unfocus();

              setState(() {
                loading = false;
                edited = false;
                newImages = [];
                originalTitle = title;
                originalContent = content;
                originalImages = new List<String>.from(oldImages);
              });
            }
          } : null,
        ),
      );
    }

    return WillPopScope(
      onWillPop: () => edited ? _showDiscardDialog() : Future.value(true),
      child: Container(
        color: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
        child: SafeArea(
          bottom: false,
          child: loading ? Loading(color: widget.tribeColor) : Scaffold(
            key: _scaffoldKey,
            backgroundColor: DynamicTheme.of(context).data.backgroundColor,
            appBar: _buildAppBar(),
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: CustomScrollBehavior(),
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 86.0, right: 16.0),
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                                      child: _buildStepIndicator(1, completed: step1Completed),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        focusNode: titleFocus,
                                        cursorRadius: Radius.circular(1000),
                                        cursorWidth: 4,
                                        initialValue: title ?? widget.post.title,
                                        textCapitalization: TextCapitalization.sentences,
                                        style: DynamicTheme.of(context).data.textTheme.title,
                                        cursorColor: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                        decoration: Decorations.postInput.copyWith(hintText: 'Title'),
                                        validator: (val) => val.isEmpty 
                                          ? 'Enter a title' 
                                          : null,
                                        onChanged: (val) {
                                          setState(() {
                                            title = val;
                                          });
                                        },
                                        onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(contentFocus),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: _buildStepIndicator(2, completed: step2Completed),
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        focusNode: contentFocus,
                                        cursorRadius: Radius.circular(1000),
                                        cursorWidth: 2,
                                        initialValue: content ?? widget.post.content,
                                        textCapitalization: TextCapitalization.sentences,
                                        style: DynamicTheme.of(context).data.textTheme.body1,
                                        cursorColor: widget.tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        decoration: Decorations.postInput.copyWith(hintText: 'Content'),
                                        validator: (val) => val.isEmpty 
                                          ? 'Enter some content' 
                                          : null,
                                        onChanged: (val) {
                                          setState((){
                                            content = val;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                              child: _buildStepIndicator(3, completed: step3Completed),
                            ),
                            Expanded(child: _buildGridView())
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: Platform.isIOS ? 8.0 : 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: _buildSaveButton(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
