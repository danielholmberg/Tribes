import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/database_service.dart';
import 'package:tribes/services/firebase_auth_service.dart';

const _OtherUserDataKey = 'otherUser-stream';
const _MessagesKey = 'messages-stream';

class PrivateMessagesViewModel extends MultipleStreamViewModel {

  // -------------- Services [START] --------------- //
  final FirebaseAuthService _authService = locator<FirebaseAuthService>();
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
  UserData get currentUserData => _databaseService.currentUserData;
  Stream<UserData> get otherUserStream => dataMap[_OtherUserDataKey];
  Stream<QuerySnapshot> get messagesStream => dataMap[_MessagesKey];
  String get notMyId => _notMyId;
  // -------------- Output [END] --------------- //

  // -------------- Logic [START] --------------- //
  // -------------- Logic [END] --------------- //

  @override
  Map<String, StreamData> get streamsMap => {
    _OtherUserDataKey: StreamData<UserData>(_databaseService.userData(_notMyId)),
    _MessagesKey: StreamData<QuerySnapshot>(_databaseService.privateChatRooms(currentUserData.id)),
  };

}