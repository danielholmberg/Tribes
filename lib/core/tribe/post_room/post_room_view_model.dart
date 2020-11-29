import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class PostRoomViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  Coordinates _coordinates;
  Future<List<Address>> _addressFuture;

  Post _post;
  Color _tribeColor;
  int _initialImage;
  bool _showTextContent;
  Function(Post) _onEditPostPress;
  TickerProvider _vsync;

  bool _isShowingTextContent = false;
  bool _isShowingOverlayWidgets = true;
  double _opacity = 0.9;
  Duration _overlayAnimDuration = const Duration(milliseconds: 300);

  // Fade-in animation
  AnimationController _fadeInController;
  Animation<double> _fadeInAnimation;

  // Liked animation
  AnimationController _likedAnimationController;
  Animation _likedAnimation;
  bool _showLikedAnimation = false;

  Future<List<Address>> get addressFuture => _addressFuture;

  Post get post => _post;
  Color get tribeColor => _tribeColor;
  int get initialImage => _initialImage;
  bool get showTextContent => _showTextContent;
  Function(Post) get onEditPostPress => _onEditPostPress;
  TickerProvider get vsync => _vsync;

  bool get isShowingTextContent => _isShowingTextContent;
  bool get isShowingOverlayWidgets => _isShowingOverlayWidgets;
  double get opacity => _opacity;
  Duration get overlayAnimDuration => _overlayAnimDuration;

  MyUser get currentUser => _databaseService.currentUserData;
  String get currentUserId => currentUser.id;
  String get authorId => _post.author;
  bool get isAuthor => currentUserId.compareTo(authorId) == 0;

  AnimationController get fadeInController => _fadeInController;
  Animation<double> get fadeInAnimation => _fadeInAnimation;

  AnimationController get likedAnimationController => _likedAnimationController;
  Animation get likedAnimation => _likedAnimation;
  bool get showLikedAnimation => _showLikedAnimation;

  Stream<MyUser> get authorData => _databaseService.userData(authorId);

  void initState({
    @required Post post,
    Color tribeColor = Constants.primaryColor,
    int initialImage = 0,
    bool showTextContent = false,
    Function(Post) onEditPostPress,
    TickerProvider vsync,
    bool isMounted,
  }) {
    _post = post;
    _tribeColor = tribeColor;
    _initialImage = initialImage;
    _showTextContent = showTextContent;
    _onEditPostPress = onEditPostPress;
    _vsync = vsync;

    // StatusBar Color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: tribeColor.withOpacity(0.6),
      ),
    );

    if ((post.lat != 0 && post.lng != 0)) {
      _coordinates = Coordinates(post.lat, post.lng);
      _addressFuture =
          Geocoder.local.findAddressesFromCoordinates(_coordinates);
    }

    _fadeInController = AnimationController(
        vsync: vsync, duration: Duration(milliseconds: 500));
    _fadeInAnimation =
        CurvedAnimation(parent: _fadeInController, curve: Curves.easeIn);

    _fadeInController.addListener(() {
      if (isMounted) notifyListeners();
    });

    _fadeInController.forward();

    _likedAnimationController = new AnimationController(
        vsync: vsync, duration: Duration(milliseconds: 800));
    _likedAnimation = Tween(begin: 20.0, end: 100.0).animate(CurvedAnimation(
        curve: Curves.bounceOut, parent: _likedAnimationController));

    _likedAnimationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _showLikedAnimation = false;
        notifyListeners();
        _likedAnimationController.reset();
      }
    });

    _isShowingTextContent = showTextContent;
  }

  void onSavePost(Post updatedPost) {
    _post = updatedPost;
    notifyListeners();
  }

  void onLike() {
    _showLikedAnimation = true;
    notifyListeners();
    _likedAnimationController.forward();
  }

  void onShowTextContent() {
    _isShowingTextContent = !_isShowingTextContent;
    notifyListeners();
  }

  void _resetStatusBar() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: tribeColor,
    ));
  }

  void onExitPress() {
    _resetStatusBar();
    _navigationService.back();
  }

  Future<bool> onWillPop() {
    _resetStatusBar();
    return Future.value(true);
  }

  void onBodyPress() {
    if (_isShowingOverlayWidgets) {
      _isShowingOverlayWidgets = false;
      SystemChrome.setEnabledSystemUIOverlays([]);
    } else {
      _isShowingOverlayWidgets = true;
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _likedAnimationController.dispose();
    _resetStatusBar();
    super.dispose();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
