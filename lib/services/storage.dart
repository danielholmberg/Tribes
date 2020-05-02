import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:tribes/services/database.dart';

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

  Future<StorageReference> getReferenceFromUrl(String fullUrl) async {
    final StorageReference ref = await FirebaseStorage.instance.getReferenceFromUrl(fullUrl);
    if (ref != null) {
      return ref;
    } else {
      return null;
    }
  }

  Future deleteOldFile(String oldImageURL) async {
    StorageReference imageRef = await getReferenceFromUrl(oldImageURL);
    if(imageRef != null) {
      return imageRef.delete();
    } else {
      print('Unable to delete old image: $oldImageURL');
      return null;
    }
  }

  Future<String> uploadUserImage(File newImageFile, String oldImageURL) async {    
    StorageReference storageReference = userImagesRoot.child('${Path.basename(newImageFile.path)}');    
    StorageUploadTask uploadTask = storageReference.putFile(newImageFile);    
    await uploadTask.onComplete; 

    print('File Uploaded');    

    String picURL = await storageReference.getDownloadURL();
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
    StorageReference ref = StorageService().postImagesRoot.child(postID).child('${asset.name}');
    StorageUploadTask uploadTask = ref.putData(imageData);

    return await (await uploadTask.onComplete).ref.getDownloadURL();
  }

  Future deleteFile(String fileURL) async {
    StorageReference fileRef = await getReferenceFromUrl(fileURL);
    if(fileRef != null) {
      return fileRef.delete();
    } else {
      print('Unable to delete file: $fileURL');
      return null;
    }
  }
}
