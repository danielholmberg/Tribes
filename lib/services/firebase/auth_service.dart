import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:observable_ish/observable_ish.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

import '../dialog_service.dart';

class AuthService with ReactiveServiceMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  StreamSubscription _firebaseUserStreamSub;

  RxValue<User> _currentFirebaseUser = RxValue<User>(
    initial: FirebaseAuth.instance.currentUser,
  );
  User get currentFirebaseUser => _currentFirebaseUser.value;

  AuthService() {
    listenToReactiveValues([
      _currentFirebaseUser,
    ]);
  }

  // ignore: close_sinks
  final StreamController<MyUser> userStreamController =
      StreamController<MyUser>.broadcast();
  Stream<MyUser> get userStream =>
      userStreamController.stream.asBroadcastStream();

  void initListener() {
    print('Initializing Auth listener...');
    _firebaseUserStreamSub =
        _auth.authStateChanges().listen((User firebaseUser) async {
      if (firebaseUser != null) {
        await locator<DatabaseService>().fetchCurrentUserData(firebaseUser.uid);
      }

      _currentFirebaseUser.value = firebaseUser;
    });
    print('Success!');
  }

  void disposeListener() {
    print('Dispose Auth listener...');
    _firebaseUserStreamSub.cancel();
    print('Success!');
  }

  String _handleError(error) {
    print(error);
    String errorMessage;
    switch (error.code) {
      case "invalid-email":
        errorMessage = "Your email address appears to be malformed.";
        break;
      case "wrong-password":
        errorMessage = "Your password is wrong.";
        break;
      case "user-not-found":
        errorMessage = "User with this email doesn't exist.";
        break;
      case "user-disabled":
        errorMessage = "User with this email has been disabled.";
        break;
      case "too-many-requests":
        errorMessage = "Too many requests. Try again later.";
        break;
      case "operation-not-allowed":
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      case "email-already-in-use":
        errorMessage = "There is already an account linked with that email.";
        break;
      default:
        errorMessage = "An undefined Error happened.";
    }
    return errorMessage;
  }

  // Sign-in with Email & Password
  Future signInWithEmailAndPassword(String email, String password) async {
    String errorMessage;
    User firebaseUser;

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebaseUser = result.user;

      await _setUserLocation();
    } catch (error) {
      errorMessage = _handleError(error);
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }

    return _currentFirebaseUser.value = firebaseUser;
  }

  // Register with Email & Password
  Future registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    String errorMessage;
    User firebaseUser;

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      firebaseUser = result.user;

      // Create User Document in Database
      await locator<DatabaseService>()
          .createUserDocument(firebaseUser.uid, name, email);
      await _setUserLocation();

      return _currentFirebaseUser.value = firebaseUser;
    } catch (error) {
      print(error);
      errorMessage = _handleError(error);
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }

    return _currentFirebaseUser.value = firebaseUser;
  }

  Future _setUserLocation() async {
    Position location = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    return await DatabaseService().updateUserLocation(
      location != null ? location.latitude : Constants.initialLat,
      location != null ? location.longitude : Constants.initialLng,
    );
  }

  Future signInWithGoogle() async {
    if (await _googleSignIn.isSignedIn()) await _googleSignIn.disconnect();

    try {
      GoogleSignInAccount signedInAccount =
          await _googleSignIn.signInSilently();

      if (signedInAccount == null) {
        // Prompt the user to Sign in again.
        UserCredential userCredential;

        if (kIsWeb) {
          GoogleAuthProvider googleProvider = GoogleAuthProvider();
          userCredential =
              await FirebaseAuth.instance.signInWithPopup(googleProvider);
        } else {
          // Trigger the authentication flow
          final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

          // The SignIn-flow has been cancelled if the returned GoogleSignInAccount is null, stop here.
          if (googleUser == null) return null;

          // Obtain the auth details from the request
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;

          // Create a new credential
          final GoogleAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          userCredential = await FirebaseAuth.instance.signInWithCredential(
            credential,
          );

          assert(!userCredential.user.isAnonymous);
          assert(await userCredential.user.getIdToken() != null);
        }

        _currentFirebaseUser.value = userCredential.user;
      }

      final bool userAlreadyCreated =
          await locator<DatabaseService>().doesUserExist(
        currentFirebaseUser == null
            ? signedInAccount.id
            : currentFirebaseUser.uid,
      );

      if (!userAlreadyCreated) {
        await DatabaseService().createUserDocument(
          currentFirebaseUser == null
              ? signedInAccount.id
              : currentFirebaseUser.uid,
          currentFirebaseUser == null
              ? signedInAccount.displayName
              : currentFirebaseUser.displayName,
          currentFirebaseUser == null
              ? signedInAccount.email
              : currentFirebaseUser.email,
        );
        await _setUserLocation();
      }

      print('User \'${currentFirebaseUser.toString()}\' signed in with Google');
    } on PlatformException catch (error) {
      print('Error signing in with Google: $error');

      if (error.code == 'network_error') {
        DialogResponse response =
            await locator<DialogService>().showCustomDialog(
          variant: DialogType.RETRY_LIGHT,
          title: 'No internet access',
          description: 'Google sign in failed due to no internet access.',
          barrierDismissible: true,
          showIconInMainButton: true,
          mainButtonTitle: 'Retry',
        );

        if (response != null && response.confirmed) await signInWithGoogle();
      }
    } catch (error) {
      print('Error signing in with Google: $error');
    }
  }

  Future signOut() async {
    print('Signing out...');

    try {
      if (await _googleSignIn.isSignedIn()) {
        await signOutGoogle();
      }
    } catch (error) {
      print(error);
    }

    return await _auth.signOut();
  }

  Future<GoogleSignInAccount> signOutGoogle() async {
    print('Signing out from Google...');
    return await _googleSignIn.disconnect();
  }
}
