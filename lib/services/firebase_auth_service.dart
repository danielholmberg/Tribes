import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class FirebaseAuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final DatabaseService _databaseService = locator<DatabaseService>();
  
  User _firebaseUser;
  User get currentFirebaseUser => _firebaseUser;
  
  // ignore: close_sinks
  final StreamController<UserData> userStreamController = StreamController<UserData>.broadcast();
  Stream<UserData> get userStream => userStreamController.stream.asBroadcastStream();

  // Create User object from FirebaseUser
  User userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(id: user.uid) : null;
  }

  // Auth-change user stream
  Stream<User> get user => _auth.onAuthStateChanged.map((FirebaseUser user) {
    if(user == null) return null;

    _firebaseUser = userFromFirebaseUser(user);
    return _firebaseUser;
  });

  String handleError(error) {
    String errorMessage;
    switch (error.code) {
      case "ERROR_INVALID_EMAIL":
        errorMessage = "Your email address appears to be malformed.";
        break;
      case "ERROR_WRONG_PASSWORD":
        errorMessage = "Your password is wrong.";
        break;
      case "ERROR_USER_NOT_FOUND":
        errorMessage = "User with this email doesn't exist.";
        break;
      case "ERROR_USER_DISABLED":
        errorMessage = "User with this email has been disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        errorMessage = "Too many requests. Try again later.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      default:
        errorMessage = "An undefined Error happened.";
    }
    return errorMessage;
  }

  // Sign-in with Email & Password
  Future signInWithEmailAndPassword(String email, String password) async {
    String errorMessage;
    FirebaseUser user;

    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user = result.user;

      Position location = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, 
        locationPermissionLevel: GeolocationPermission.locationAlways
      );

      await DatabaseService().updateUserLocation(
        location != null ? location.latitude : Constants.initialLat, 
        location != null ? location.longitude : Constants.initialLng,
      ); 
    } catch (error) {
      print(error);
      errorMessage = handleError(error);
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }

    return userFromFirebaseUser(user);
  }

  // Register with Email & Password
  Future registerWithEmailAndPassword(String email, String password, String name) async {
    String errorMessage;
    FirebaseUser user;

    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = result.user;

      // Create User Document in Database
      await DatabaseService().createUserDocument(user.uid, name, email);
      await _setUserLocation();

      return userFromFirebaseUser(user); 
    } catch (error) {
      print(error);
      errorMessage = handleError(error);
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }

    return userFromFirebaseUser(user);
  }

  Future _setUserLocation() async {
    Position location = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, 
        locationPermissionLevel: GeolocationPermission.locationAlways
      );
      
    return await DatabaseService().updateUserLocation(
      location != null ? location.latitude : Constants.initialLat, 
      location != null ? location.longitude : Constants.initialLng,
    );
  }

  // Sign out
  Future signOut() async {
    String errorMessage;

    try {
      print('Signing out...');
      if(await googleSignIn.isSignedIn()) {
        signOutGoogle();
      }
    } catch (error) {
      print(error);
      errorMessage = handleError(error);
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }

    return _auth.signOut();
  }

  // Sign in with Google Auth
  Future<dynamic> signInWithGoogle() async {
    String errorMessage;
    FirebaseUser user;

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    try {
      if(googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final AuthResult authResult = await _auth.signInWithCredential(credential);
        user = authResult.user;

        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final FirebaseUser currentUser = await _auth.currentUser();
        assert(user.uid == currentUser.uid);

        final bool userExists = await _databaseService.doesUserExist(currentUser.uid);

        if(!userExists) {
          await DatabaseService().createUserDocument(user.uid, user.displayName, user.email);
          await _setUserLocation();
        }

        print('User \'${currentUser.uid}\' signed in with Google');
      }
    } catch (error) {
      print('Error signing in with Google: $error');
      errorMessage = handleError(error);
    }

    if (errorMessage != null) {
      return Future.error(errorMessage);
    }

    return userFromFirebaseUser(user);
  }

  // Sign out from Google Auth
  void signOutGoogle() async {
    print('Signing out Google...');
    await googleSignIn.signOut();
  }

}