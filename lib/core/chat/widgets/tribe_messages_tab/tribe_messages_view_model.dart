import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase_auth_service.dart';

class TribeMessagesViewModel extends StreamViewModel<UserData> {

  // -------------- Services [START] --------------- //
  final FirebaseAuthService _authService = locator<FirebaseAuthService>();
  // -------------- Services [END] --------------- //
  
  // -------------- Models [START] --------------- //
  // -------------- Models [END] --------------- //

  // -------------- State [START] --------------- //
  // -------------- State [END] --------------- //

  // -------------- Input [START] --------------- //
  // -------------- Input [END] --------------- //

  // -------------- Output [START] --------------- //
  UserData get currentUser => data;
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //
  // -------------- Logic [END] --------------- //

  @override
  Stream<UserData> get stream => _authService.userStream;

}