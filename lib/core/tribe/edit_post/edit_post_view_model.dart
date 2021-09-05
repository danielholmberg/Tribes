import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/services/firebase/storage_service.dart';

class EditPostViewModel extends ReactiveViewModel {
  final Color tribeColor;
  final Function(Post) onSave;
  final Function onDelete;
  EditPostViewModel({
    @required this.tribeColor,
    @required this.onSave,
    @required this.onDelete,
  });

  final DatabaseService _databaseService = locator<DatabaseService>();
  final StorageService _storageService = locator<StorageService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocus = new FocusNode();
  final FocusNode _contentFocus = new FocusNode();

  BuildContext _context;
  bool _isMounted = false;
  Post _post;
  String _tribeColor = '';

  bool _photoButtonIsDisabled;

  String _title;
  String _content;
  List<String> _oldImages = [];
  String _originalTitle;
  String _originalContent;
  List<String> _originalImages = [];

  List<Asset> _newImages = [];

  GlobalKey<FormState> get formKey => _formKey;
  FocusNode get titleFocus => _titleFocus;
  FocusNode get contentFocus => _contentFocus;

  bool get photoButtonIsDisabled => _photoButtonIsDisabled;

  String get title => _title ?? _post.title;
  String get content => _content ?? _post.content;
  List<String> get oldImages => _oldImages;
  String get originalTitle => _originalTitle;
  String get originalContent => _originalContent;
  List<String> get originalImages => _originalImages;

  List<Asset> get newImages => _newImages;

  int get oldImagesCount => _oldImages.length;
  int get newImagesCount => _newImages.length;
  int get imagesCount => oldImagesCount + newImagesCount;

  bool get edited =>
      _originalTitle != _title ||
      _originalContent != _content ||
      _newImages.length > 0 ||
      (_originalImages.length != _oldImages.length);
  bool get step1Completed => _title.trim().isNotEmpty;
  bool get step2Completed => _content.trim().isNotEmpty;
  bool get step3Completed => _oldImages.length + _newImages.length > 0;

  bool get completed => step1Completed && step2Completed && step3Completed;

  int get maxImages => 5;

  void initState({
    @required BuildContext context,
    @required bool isMounted,
    @required Post post,
  }) {
    _context = context;
    _isMounted = isMounted;
    _post = post;
    _tribeColor = '#${tribeColor.value.toRadixString(16)}';

    _originalTitle = post.title;
    _originalContent = post.content;
    _originalImages = new List<String>.from(post.images);
    _photoButtonIsDisabled = _originalImages.length == maxImages;

    _title = _originalTitle;
    _content = _originalContent;
    _oldImages = new List<String>.from(_originalImages);

    Future.delayed(Duration(milliseconds: 650)).then((val) {
      FocusScope.of(context).requestFocus(titleFocus);
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList;

    try {
      int remainingImages = maxImages - imagesCount;
      String title = remainingImages == maxImages
          ? "Add images"
          : "Add $remainingImages more image${remainingImages > 1 ? 's' : ''}";

      resultList = await MultiImagePicker.pickImages(
        maxImages: remainingImages,
        enableCamera: true,
        materialOptions: MaterialOptions(
          actionBarTitle: title,
          allViewTitle: title,
          actionBarColor: _tribeColor, // TO-DO: Change
          actionBarTitleColor: "#ffffff", // TO-DO: Change
          lightStatusBar: false,
          useDetailsView: true,
          statusBarColor: _tribeColor, // TO-DO: Change
          startInAllView: true,
          selectCircleStrokeColor: _tribeColor, // TO-DO: Change
          selectionLimitReachedText: "You can't add any more.",
        ),
        cupertinoOptions: CupertinoOptions(
          selectionFillColor: _tribeColor, // TO-DO: Change
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
      _newImages = _newImages + resultList;
      _photoButtonIsDisabled = imagesCount == maxImages;
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

  void back() {
    _navigationService.back();
  }

  Future onDeletePostConfirm() async {
    await _databaseService.deletePost(_post);
    back(); // Dialog: "Are you sure...?"
    back(); // PostTile

    if (onDelete != null) {
      onDelete();
    }
  }

  void onRemoveImage(int index, bool isNewImage) {
    isNewImage ? _newImages.removeAt(index) : _oldImages.removeAt(index);
    _photoButtonIsDisabled = imagesCount == maxImages;
    notifyListeners();
  }

  Future onNewImage() async {
    await loadAssets();
  }

  Future onStepIndicatorPress(int number) async {
    switch (number) {
      case 1:
        titleFocus.requestFocus();
        break;
      case 2:
        contentFocus.requestFocus();
        break;
      case 3:
        if (!photoButtonIsDisabled) await loadAssets();
        break;
      default:
        return;
    }
  }

  Future onSavePost() async {
    if (_formKey.currentState.validate() && imagesCount > 0) {
      setBusy(true);
      List<String> imageURLs = [];

      for (Asset image in newImages) {
        String imageURL = await _storageService.uploadPostImage(
          _post.id,
          image,
        );
        imageURLs.add(imageURL);
      }

      _oldImages += imageURLs;

      _databaseService.updatePostData(
        postID: _post.id,
        title: title ?? _post.title,
        content: content ?? _post.content,
        images: oldImages ?? _post.images,
      );

      if (onSave != null) {
        onSave(_post.copyWith(
          title: title,
          content: content,
          images: oldImages,
        ));
      }

      if (newImages.length == 0) {
        ScaffoldMessenger.of(_context).showSnackBar(SnackBar(
          content: Text(
            'Post saved',
            style: TextStyle(fontFamily: 'TribesRounded'),
          ),
          duration: Duration(milliseconds: 500),
        ));
      }

      FocusScope.of(_context).unfocus();

      setBusy(false);
      _newImages = [];
      _originalTitle = title;
      _originalContent = content;
      _originalImages = new List<String>.from(oldImages);
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
