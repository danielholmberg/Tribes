import 'dart:async';
import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/services/storage.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomButton.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/DiscardChangesDialog.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class NewPost extends StatefulWidget {  
  final Tribe tribe;
  NewPost({@required this.tribe});

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  
  final _formKey = GlobalKey<FormState>();
  final FocusNode titleFocus = new FocusNode();
  final FocusNode contentFocus = new FocusNode();
  bool loading = false;
  bool photoButtonIsDisabled = false;
  
  String title = '';
  String content = '';
  String tribeColor = '';

  List<Asset> images = [];

  @override
  void initState() {
    tribeColor = widget.tribe.color.value.toRadixString(16);
    super.initState();
  }

  @override
  void dispose() {
    titleFocus.dispose();
    contentFocus.dispose();
    super.dispose();
  }

  Future<void> _loadAssets() async {
    List<Asset> resultList;

    try {
      int remainingImages = 5 - images.length;
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
        images = images + resultList;
        photoButtonIsDisabled = images.length == 5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building NewPost()...');
    print('Current user ${currentUser.toString()}');

    bool edited = title.isNotEmpty || content.isNotEmpty || images.length > 0;
    bool step1Completed = title.trim().isNotEmpty;
    bool step2Completed = content.trim().isNotEmpty;
    bool step3Completed = images.length > 0;

    _buildAppBar() {
      return AppBar(
        elevation: 0.0,
        backgroundColor: DynamicTheme.of(context).data.backgroundColor,
        leading: IconButton(
          icon: CustomAwesomeIcon(
            icon: FontAwesomeIcons.times, 
            color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
          ), 
          onPressed: () {
            if(edited) {
              showDialog(
                context: context,
                builder: (context) => DiscardChangesDialog(color: widget.tribe.color)
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: <Widget>[],
      );
    }

    _buildNewImageIcon() {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomAwesomeIcon(
            icon: FontAwesomeIcons.camera, 
            size: 30,
            color: widget.tribe.color.withOpacity(photoButtonIsDisabled ? 0.4 : 1.0),
          ), 
          Positioned(
            left: 30,
            top: 30,
            child: Container(
              child: CustomAwesomeIcon(
                icon: FontAwesomeIcons.plus, 
                size: 14, 
                color: widget.tribe.color.withOpacity(photoButtonIsDisabled ? 0.4 : 1.0),
                strokeWidth: 2.0,
              ),
            ),
          ),
        ],
      );
    }

    _buildGridView() {
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
                  color: widget.tribe.color.withOpacity(photoButtonIsDisabled ? 0.4 : 1.0),
                ),
              ),
              child: _buildNewImageIcon(),
            ),
          ),
        ] + List.generate(images.length, (index) {
          int _imageNumber = index + 1;
          Asset asset = images[index];
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
                  AssetThumb(
                    asset: asset,
                    width: 300,
                    height: 300,
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
                          images.removeAt(index);
                          setState(() {
                            photoButtonIsDisabled = images.length == 5;
                          });
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Visibility(
                      visible: images.length > 1,
                      child: Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: widget.tribe.color.withOpacity(0.6),
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
        })
      );
    }

    _buildPublishButton() {
      return Visibility(
        visible: step1Completed && step2Completed && step3Completed,
        child: CustomButton(
          icon: FontAwesomeIcons.check,
          height: 60.0, 
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(16.0),
          label: Text('Publish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
          color: Colors.green,
          iconColor: Colors.white,
          onPressed: () async {                
            if(_formKey.currentState.validate() && images.length > 0) {
              setState(() => loading = true);
              List<String> imageURLs = [];

              await Future.forEach(images, (image) async {
                String imageURL = await StorageService().uploadPostImage(image);
                imageURLs.add(imageURL);
              });
              
              DatabaseService().addNewPost(
                currentUser.uid, 
                title, 
                content, 
                imageURLs, 
                widget.tribe.id
              );

              Navigator.pop(context);
            }
          },
        ),
      );
    }

    _buildStepIndicator(int number, {bool completed = false}) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: completed ? widget.tribe.color.withOpacity(0.6) : Colors.transparent,
          borderRadius: BorderRadius.circular(1000),
          border: Border.all(color: widget.tribe.color, width: 2.0)
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
              color: widget.tribe.color,
              fontFamily: 'TribesRounded',
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () {
        if(loading) {
          return Future.value(false);
        } else if(edited) {
          showDialog(
            context: context,
            builder: (context) => DiscardChangesDialog(color: widget.tribe.color)
          );
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Container(
        color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
        child: SafeArea(
          bottom: false,
          child: loading ? Loading(color: widget.tribe.color) 
          : Scaffold(
            backgroundColor: DynamicTheme.of(context).data.backgroundColor,
            extendBody: true,
            appBar: _buildAppBar(),
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: CustomScrollBehavior(),
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 76.0, right: 16.0),
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
                                        textCapitalization: TextCapitalization.sentences,
                                        style: DynamicTheme.of(context).data.textTheme.title,
                                        cursorColor: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                        decoration: Decorations.postInput.copyWith(hintText: 'Title'),
                                        onChanged: (val) {
                                          setState(() => title = val);
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
                                        textCapitalization: TextCapitalization.sentences,
                                        style: DynamicTheme.of(context).data.textTheme.body1,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        textAlign: TextAlign.start,
                                        textAlignVertical: TextAlignVertical.top,
                                        cursorColor: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                        decoration: Decorations.postInput.copyWith(hintText: 'Content'),
                                        onChanged: (val) {
                                          setState(() => content = val);
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
                  child: _buildPublishButton(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  } 
}
