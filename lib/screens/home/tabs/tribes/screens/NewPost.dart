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
  NewPost({this.tribe});

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  
  final _formKey = GlobalKey<FormState>();
  final FocusNode titleFocus = new FocusNode();
  final FocusNode contentFocus = new FocusNode();
  bool loading = false;
  bool photoVideoButtonIsDisabled = false;
  
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

  Widget buildGridView() {
    return images.length == 0 ? SizedBox.shrink() : 
    GridView.count(
      crossAxisCount: 3,
      padding: Constants.imageGridViewPadding,
      shrinkWrap: true,
      crossAxisSpacing: Constants.imageGridViewCrossAxisSpacing,
      mainAxisSpacing: Constants.imageGridViewMainAxisSpacing,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return PhotoView.customChild(
          backgroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: widget.tribe.color.withOpacity(0.4), width: 2),
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
                          photoVideoButtonIsDisabled = images.length == 5;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
        materialOptions: MaterialOptions(
          actionBarTitle: "Select image(s)",
          allViewTitle: "Select image(s)",
          actionBarColor: "#ed217c",  // TO-DO: Change
          actionBarTitleColor: "#ffffff",  // TO-DO: Change
          lightStatusBar: false,
          statusBarColor: '#ed217c',  // TO-DO: Change
          startInAllView: true,
          selectCircleStrokeColor: "#ed217c", // TO-DO: Change
          selectionLimitReachedText: "You can't select any more.",
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
        images = resultList;
        photoVideoButtonIsDisabled = images.length == 5;
      });
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
          child: loading ? Loading(color: widget.tribe.color) : Scaffold(
            backgroundColor: DynamicTheme.of(context).data.backgroundColor,
            extendBody: true,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: DynamicTheme.of(context).data.backgroundColor,
              leading: IconButton(
                icon: CustomAwesomeIcon(
                  icon: FontAwesomeIcons.times, 
                  color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                ), 
                onPressed: () {
                  if(title.isNotEmpty || content.isNotEmpty || images.length > 0) {
                    showDialog(
                      context: context,
                      builder: (context) => DiscardChangesDialog(color: widget.tribe.color)
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: CustomAwesomeIcon(
                    icon: FontAwesomeIcons.photoVideo,
                    color: (widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor).withOpacity(photoVideoButtonIsDisabled ? 0.4 : 1.0),
                  ),                  
                  onPressed: photoVideoButtonIsDisabled ? null : () async => await loadAssets(),
                ),
                SizedBox(width: 8.0)
              ],
            ),
            body: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: CustomScrollBehavior(),
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 76.0),
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      decoration: Decorations.postInput.copyWith(hintText: 'Title'),
                                      validator: (val) => val.isEmpty 
                                        ? 'Enter a title' 
                                        : null,
                                      onChanged: (val) {
                                        setState(() => title = val);
                                      },
                                      onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(contentFocus),
                                    ),
                                    TextFormField(
                                      focusNode: contentFocus,
                                      textCapitalization: TextCapitalization.sentences,
                                      style: DynamicTheme.of(context).data.textTheme.body1,
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      cursorColor: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                      decoration: Decorations.postInput.copyWith(hintText: 'Content'),
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
                        buildGridView(),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: Platform.isIOS ? 8.0 : 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: (title.isNotEmpty || content.isNotEmpty || images.length > 0) ? 1.0 : 0.0,
                    child: CustomButton(
                      icon: FontAwesomeIcons.check,
                      height: 60.0, 
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.all(16.0),
                      label: Text('Publish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
                      color: Colors.green,
                      iconColor: Colors.white,
                      onPressed: () async {                
                        if(_formKey.currentState.validate()) {
                          setState(() => loading = true);
                          List<String> imageURLs = [];

                          if(images.length > 0) {
                            await Future.forEach(images, (image) async {
                              String imageURL = await StorageService().uploadPostImage(image);
                              imageURLs.add(imageURL);
                            });
                          }
                          
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
