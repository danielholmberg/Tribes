import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class TribeRoomViewModel extends ReactiveViewModel {
  final String tribeId;
  final Color tribeColor;
  TribeRoomViewModel({
    @required this.tribeId,
    @required this.tribeColor,
  });

  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final GlobalKey _postsKey = GlobalKey();

  GlobalKey get postsKey => _postsKey;

  double get calculatePostsHeight {
    RenderBox postsContainer = _postsKey.currentContext.findRenderObject();
    return postsContainer.size.height;
  }

  Stream<Tribe> get tribeStream {
    return _databaseService.tribe(tribeId);
  }

  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: tribeColor,
    ));
  }

  void _resetStatusbarColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Constants.primaryColor,
    ));
  }

  void onHomePress() {
    _resetStatusbarColor();
    _navigationService.back();
  }

  Future<bool> onWillPop() {
    _resetStatusbarColor();
    return Future.value(true);
  }

  @override
  void dispose() {
    _resetStatusbarColor();
    super.dispose();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
