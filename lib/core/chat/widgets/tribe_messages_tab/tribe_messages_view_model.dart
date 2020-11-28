import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';

class TribeMessagesViewModel extends StreamViewModel<List<Tribe>> {

  // -------------- Services [START] --------------- //
  final DatabaseService _databaseService = locator<DatabaseService>();
  // -------------- Services [END] --------------- //
  
  // -------------- Models [START] --------------- //
  // -------------- Models [END] --------------- //

  // -------------- State [START] --------------- //
  // -------------- State [END] --------------- //

  // -------------- Input [START] --------------- //
  // -------------- Input [END] --------------- //

  // -------------- Output [START] --------------- //
  MyUser get currentUser => _databaseService.currentUserData;
  List<Tribe> get joinedTribes => data;
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //
  // -------------- Logic [END] --------------- //

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