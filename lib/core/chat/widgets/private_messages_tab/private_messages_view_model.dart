import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';

const _OtherUserDataKey = 'otherUser-stream';
const _MessagesKey = 'messages-stream';

class PrivateMessagesViewModel extends BaseViewModel {

  // -------------- Services [START] --------------- //
  final DatabaseService _databaseService = locator<DatabaseService>();
  // -------------- Services [END] --------------- //
  
  // -------------- Models [START] --------------- //
  // -------------- Models [END] --------------- //

  // -------------- State [START] --------------- //
  String _notMyId;
  // -------------- State [END] --------------- //

  // -------------- Input [START] --------------- //
  void setNotMyId(String uid) => _notMyId = uid;
  // -------------- Input [END] --------------- //

  // -------------- Output [START] --------------- //
  MyUser get currentUserData => _databaseService.currentUserData;
  Stream<MyUser> get otherUserDataStream => _databaseService.userData(_notMyId);
  Query get privateChatRooms => _databaseService.privateChatRooms(currentUserData.id);
  String get notMyId => _notMyId;
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //
  // -------------- Logic [END] --------------- //

}