import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
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
    if(oldImageURL.isNotEmpty) {
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

  Future<String> uploadFile(File newFile) async {    
    StorageReference storageReference = StorageService().postImagesRoot.child('${Path.basename(newFile.path)}');    
    StorageUploadTask uploadTask = storageReference.putFile(newFile);    
    await uploadTask.onComplete;    
    print('File Uploaded');    
    return await storageReference.getDownloadURL();    
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
