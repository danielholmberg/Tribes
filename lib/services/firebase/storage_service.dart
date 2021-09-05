import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:tribes/services/firebase/database_service.dart';

class StorageService {
  // User Image Ref
  final Reference userImagesRoot =
      FirebaseStorage.instance.ref().child('userImages');

  // User Image Ref
  final Reference postImagesRoot =
      FirebaseStorage.instance.ref().child('postImages');

  // Tribe Image Ref
  final Reference tribeImagesRoot =
      FirebaseStorage.instance.ref().child('tribeImages');

  Reference getReferenceFromUrl(String fullUrl) {
    print('getRefFromUrl: $fullUrl');
    final Reference ref = FirebaseStorage.instance.ref(fullUrl);
    if (ref != null) {
      return ref;
    } else {
      return null;
    }
  }

  Future deleteOldFile(String oldImageURL) {
    Reference imageRef = getReferenceFromUrl(oldImageURL);
    if(imageRef != null) {
      return imageRef.delete();
    } else {
      print('Unable to delete old image: $oldImageURL');
      return null;
    }
  }

  Future<String> uploadUserImage(File newImageFile, String oldImageURL) async {
    Reference storageRef = userImagesRoot.child('${Path.basename(newImageFile.path)}');

    await storageRef.putFile(newImageFile);

    print('File Uploaded');

    String picURL = await storageRef.getDownloadURL();
    if(oldImageURL != null) {
      try {
        await deleteOldFile(oldImageURL);
      } catch (e) {
        print('Unable to delete old image: ${e.toString()}');
        return null;
      }
    }
    await DatabaseService().updateUserPicURL(picURL);
    return picURL;
  }

  Future<String> uploadPostImage(String postID, Asset asset) async {
    ByteData byteData = await asset.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();
    Reference ref = StorageService().postImagesRoot.child(postID).child('${asset.name}');

    await ref.putData(imageData);

    return await ref.getDownloadURL();
  }

  Future deleteFile(String fileURL) async {
    Reference fileRef = await getReferenceFromUrl(fileURL);
    if(fileRef != null) {
      return fileRef.delete().then((onValue) => print('Deleted image with URL: $fileURL'));
    } else {
      print('Unable to delete file: $fileURL');
      return Future.value(null);
    }
  }

  Future deletePostImages(String postID) {
    return FirebaseFunctions.instance.httpsCallable('deletePostImages').call({
      'postID': postID,
    });
  }
}
