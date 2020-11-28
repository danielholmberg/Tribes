import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/services/firebase/storage_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/discard_changes_dialog.dart';

class NewPostViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final StorageService _storageService = locator<StorageService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocus = new FocusNode();
  final FocusNode _contentFocus = new FocusNode();

  BuildContext _context;
  Tribe _tribe;

  bool _isMounted = false;
  bool _photoButtonIsDisabled = false;

  String _title = '';
  String _content = '';
  String _tribeColor = '';

  List<Asset> _images = [];

  GlobalKey<FormState> get formKey => _formKey;
  FocusNode get titleFocus => _titleFocus;
  FocusNode get contentFocus => _contentFocus;

  MyUser get currentUser => _databaseService.currentUserData;

  bool get photoButtonIsDisabled => _photoButtonIsDisabled;

  String get title => _title;
  String get content => _content;
  Color get tribeColor => _tribe.color ?? Constants.primaryColor;

  List<Asset> get images => _images;
  int get imagesCount => _images.length;

  bool get edited =>
      _title.isNotEmpty || _content.isNotEmpty || _images.length > 0;
  bool get step1Completed => _title.trim().isNotEmpty;
  bool get step2Completed => _content.trim().isNotEmpty;
  bool get step3Completed => _images.length > 0;
  bool get completedAllSteps =>
      step1Completed && step2Completed && step3Completed;

  void initState({
    BuildContext context,
    Tribe tribe,
    bool isMounted,
  }) {
    _tribe = tribe;
    _tribeColor = tribe.color.value.toRadixString(16);
    _isMounted = isMounted;
  }

  Future<void> loadAssets() async {
    List<Asset> resultList;

    try {
      int remainingImages = 5 - _images.length;
      String title = remainingImages == 5
          ? "Add images"
          : "Add $remainingImages more image${remainingImages > 1 ? 's' : ''}";

      resultList = await MultiImagePicker.pickImages(
        maxImages: remainingImages,
        enableCamera: true,
        materialOptions: MaterialOptions(
          actionBarTitle: title,
          allViewTitle: title,
          actionBarColor: "#ed217c", // TO-DO: Change
          actionBarTitleColor: "#ffffff", // TO-DO: Change
          lightStatusBar: false,
          statusBarColor: '#ed217c', // TO-DO: Change
          startInAllView: true,
          selectCircleStrokeColor: "#ed217c", // TO-DO: Change
          selectionLimitReachedText: "You can't add any more.",
        ),
        cupertinoOptions: CupertinoOptions(
          selectionFillColor: "#ed217c", // TO-DO: Change
          selectionTextColor: "#ffffff", // TO-DO: Change
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
    if (!_isMounted) return;

    if (resultList.length > 0) {
      _images = _images + resultList;
      _photoButtonIsDisabled = _images.length == 5;
    }

    notifyListeners();
  }

  void onTitleChanged(String value) {
    _title = value;
    notifyListeners();
  }

  void onContentChanged(String value) {
    _content = value;
    notifyListeners();
  }

  void onTitleSubmitted(String value) {
    FocusScope.of(_context).requestFocus(_contentFocus);
  }

  void onExit() {
    if (edited) {
      showDialog(
        context: _context,
        builder: (context) => DiscardChangesDialog(
          color: _tribe.color,
        ),
      );
    } else {
      _navigationService.back();
    }
  }

  void onRemoveImage(int index) {
    _images.removeAt(index);
    _photoButtonIsDisabled = _images.length == 5;
    notifyListeners();
  }

  Future onPublishPost() async {
    if (_formKey.currentState.validate() && images.length > 0) {
      setBusy(true);

      List<String> imageURLs = [];

      String postID = _databaseService.newPostId;

      for (Asset image in _images) {
        String imageURL = await _storageService.uploadPostImage(postID, image);
        imageURLs.add(imageURL);
      }

      await _databaseService.addNewPost(
        postID: postID,
        title: title,
        content: content,
        images: imageURLs,
        tribeID: _tribe.id,
      );
      setBusy(false);

      _navigationService.back();
    }
  }

  Future onStepIndicatorPress(int number) async {
    switch (number) {
      case 1:
        _titleFocus.requestFocus();
        break;
      case 2:
        _contentFocus.requestFocus();
        break;
      case 3:
        if (!_photoButtonIsDisabled) await loadAssets();
        break;
      default:
        return;
    }
  }

  Future<bool> onWillPop() {
    if (isBusy) {
      return Future.value(false);
    } else if (edited) {
      showDialog(
        context: _context,
        builder: (context) => DiscardChangesDialog(
          color: tribeColor,
        ),
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
