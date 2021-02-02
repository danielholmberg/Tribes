import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/chat_message_model.dart';
import 'package:tribes/models/chat_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/router.dart';
import 'package:tribes/services/firebase/database_service.dart';

class PrivateMessagesViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  String _notMyId;
  bool _hasLoaded = false;

  String get notMyId => _notMyId;
  bool get hasLoaded => _hasLoaded;

  MyUser get currentUser => _databaseService.currentUserData;
  Stream<MyUser> get friendDataStream => _databaseService.userData(_notMyId);
  Query get privateChatRooms => _databaseService.privateChatRooms;

  Stream<Message> getMostRecentMessageStream(String messageId) {
    return _databaseService.mostRecentMessage(messageId);
  }

  void onData() {
    if (!_hasLoaded) {
      Future.delayed(Duration(milliseconds: 500), () {
        _hasLoaded = true;
        notifyListeners();
      });
    }
  }

  void onPrivateChatPress(ChatData data, {bool reply = false}) {
    _navigationService.navigateTo(
      MyRouter.chatRoomRoute,
      arguments: ChatRoomArguments(
        roomId: data.id,
        members: data.members,
      ),
    );
  }

  void setNotMyId(String id) {
    _notMyId = id;
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
