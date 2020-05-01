import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Create User object from FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  // Auth-change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
      .map((FirebaseUser user) => _userFromFirebaseUser(user));
  }

  // Sign-in with Email & Password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      Position location = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, 
        locationPermissionLevel: GeolocationPermission.locationAlways
      );

      await DatabaseService().updateUserLocation(
        location != null ? location.latitude : Constants.initialLat, 
        location != null ? location.longitude : Constants.initialLng,
      );
      
      return _userFromFirebaseUser(user); 
    } catch(e) {
      print(e);
      return null;
    }
  }

  // Register with Email & Password
  Future registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      // Create User Document in Database
      await DatabaseService().createUserDocument(user.uid, name, email);
      await _setUserLocation();

      return _userFromFirebaseUser(user); 
    } catch(e) {
      print(e);
      return null;
    }
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
    try {
      print('Signing out...');
      if(await googleSignIn.isSignedIn()) {
        signOutGoogle();
      }
      return _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in with Google Auth
  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if(googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult = await _auth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);

      // Create User Document in Database
      await DatabaseService().createUserDocument(user.uid, user.displayName, user.email);
      await _setUserLocation();

      return _userFromFirebaseUser(user);
    } else {
      return null;
    }
  }

  // Sign out from Google Auth
  void signOutGoogle() async {
    print('Signing out Google...');
    await googleSignIn.signOut();
  }

}