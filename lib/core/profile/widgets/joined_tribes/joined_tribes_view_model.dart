import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/router.dart';
import 'package:tribes/services/firebase/database_service.dart';

class JoinedTribesViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  Stream<List<Tribe>> get joinedTribes => _databaseService.joinedTribes;

  void showNewTribePage() {
    _navigationService.navigateTo(MyRouter.newTribeRoute);
  }

  void showJoinTribePage() {
    _navigationService.navigateTo(MyRouter.joinTribeRoute);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
