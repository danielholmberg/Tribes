

import 'dart:io';

class UtilService {
  
  bool get isIOS {
    try{
      // Work-around as Platform-operation is not yet supported for Flutter Web.
      return Platform.isIOS;
    } catch(e) {
      return false;
    }
  }

  bool get isAndroid {
    try{
      // Work-around as Platform-operation is not yet supported for Flutter Web.
      return Platform.isAndroid;
    } catch(e) {
      return false;
    }
  }

}