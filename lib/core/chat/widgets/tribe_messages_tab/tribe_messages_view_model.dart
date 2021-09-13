import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/chat_message_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/router.dart';
import 'package:tribes/services/firebase/database_service.dart';

class TribeMessagesViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  bool _hasLoaded = false;

  bool get hasLoaded => _hasLoaded;

  MyUser get currentUser => _databaseService.currentUserData;
  Stream<List<Tribe>> get joinedTribesStream => _databaseService.joinedTribes;
  Stream<List<Message>> mostRecentMessagesStream(String tribeID, int count) => _databaseService.mostRecentMessages(tribeID, count: count);

  void showJoinTribePage() {
    _navigationService.navigateTo(MyRouter.joinTribeRoute);
  }

  void onData(List<Tribe> data) {
    if (!_hasLoaded && data != null) {
      Future.delayed(Duration(milliseconds: 1000), () {
        _hasLoaded = true;
        notifyListeners();
      });
    }
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];

}
