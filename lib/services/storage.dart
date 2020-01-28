import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  // User Image Ref
  final StorageReference userImagesRoot =
      FirebaseStorage().ref().child('userImages');

  // User Image Ref
  final StorageReference postImagesRoot =
      FirebaseStorage().ref().child('postImages');

  // Tribe Image Ref
  final StorageReference tribeImagesRoot =
      FirebaseStorage().ref().child('tribeImages');

  Future getTribeImageURL(String imageID) async {
    try {
      return await tribeImagesRoot.child(imageID).getDownloadURL();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future getUserImageURL(String imageID) async {
    try {
      return await userImagesRoot.child(imageID).getDownloadURL();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
