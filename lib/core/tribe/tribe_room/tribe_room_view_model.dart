import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/services/firebase/database_service.dart';

class TribeRoomViewModel extends ReactiveViewModel {
  final String tribeId;
  TribeRoomViewModel({@required this.tribeId});

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

  void onHomePress() {
    _navigationService.back();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
