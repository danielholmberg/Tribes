import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/services/firebase/auth_service.dart';

class AuthViewModel extends ReactiveViewModel {
  final AuthService _authService = locator<AuthService>();

  int _currentViewIndex = 0;

  int get currentViewIndex => _currentViewIndex;
  bool get isAuthenticated => _authService.currentFirebaseUser != null;

  void showSignInView() {
    _currentViewIndex = 0;
    notifyListeners();
  }

  void showRegisterView() {
    _currentViewIndex = 1;
    notifyListeners();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_authService];

}