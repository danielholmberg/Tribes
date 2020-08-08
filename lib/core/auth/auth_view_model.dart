import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase_auth_service.dart';

class AuthViewModel extends StreamViewModel<User> {

  // -------------- Services [START] --------------- //
  final FirebaseAuthService _authService = locator<FirebaseAuthService>();
  // -------------- Services [END] --------------- //

  // -------------- Models [START] --------------- //
  // -------------- Models [END] --------------- //

  // -------------- State [START] --------------- //
  int _currentViewIndex = 0;
  // -------------- State [END] --------------- //

  // -------------- Input [START] --------------- //
  // -------------- Input [END] --------------- //

  // -------------- Output [START] --------------- //
  int get currentViewIndex => _currentViewIndex;

  get isAuthenticated => this.dataReady;
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //
  void showSignInView() {
    _currentViewIndex = 0;
    notifyListeners();
  }

  void showRegisterView() {
    _currentViewIndex = 1;
    notifyListeners();
  }

  @override
  void onData(User user) async {
    print('AuthViewModel user: $user');
    super.onData(data);
  }

  @override
  Stream<User> get stream => _authService.user;
  // -------------- Logic [END] --------------- //

}