import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        user.uid,
        location != null ? location.latitude : 58.4167, 
        location != null ? location.longitude : 15.6167,
      );
      
      return _userFromFirebaseUser(user); 
    } catch(e) {
      print(e);
      return null;
    }
  }

  // Register with Email & Password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      // Create User Document in Database
      await DatabaseService().createUserDocument(user.uid);

      return _userFromFirebaseUser(user); 
    } catch(e) {
      print(e);
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    try {
      print('Signing out...');
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}