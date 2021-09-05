import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/router.dart';
import 'package:tribes/services/firebase/database_service.dart';

class TribeMessagesViewModel extends StreamViewModel<List<Tribe>> {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  MyUser get currentUser => _databaseService.currentUserData;
  List<Tribe> get joinedTribes => data;

  void showJoinTribePage() {
    _navigationService.navigateTo(MyRouter.joinTribeRoute);
  }

  @override
  void onData(List<Tribe> data) {
    print('Tribe Messages data: $data');
    super.onData(data);
  }

  @override
  void onError(error) {
    print('Error retrieving joined Tribes: ${error.toString()}');
    super.onError(error);
  }

  @override
  Stream<List<Tribe>> get stream => _databaseService.joinedTribes;

}
