import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class ChatRoomViewModel extends ReactiveViewModel {
  final String roomID;
  final Tribe currentTribe;
  final List<String> members;
  final bool reply;
  ChatRoomViewModel({
    @required this.roomID,
    this.currentTribe,
    this.members,
    this.reply,
  });

  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final TextEditingController _controller = new TextEditingController();

  BuildContext _context;

  String _message = '';
  FocusNode _textFieldFocus;

  MyUser get currentUser => _databaseService.currentUserData;
  Color get currentTribeColor =>
      currentTribe != null ? currentTribe.color : Constants.primaryColor;

  TextEditingController get controller => _controller;

  String get message => _message;
  FocusNode get textFieldFocus => _textFieldFocus;

  Stream<MyUser> get friendDataStream => _databaseService.userData(
        members.where((memberID) => memberID != currentUser.id).toList()[0],
      );

  void initState({@required BuildContext context}) {
    _context = context;
    _textFieldFocus = new FocusNode();
  }

  void onExitPress() {
    _navigationService.back();
  }

  void onAddAttachment() {
    Fluttertoast.showToast(
      msg: 'Coming soon!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void onMessageChanged(String value) {
    _message = value;
    notifyListeners();
  }

  void onSendMessage() {
    _controller.clear();
    FocusScope.of(_context).unfocus();
    _databaseService.sendChatMessage(roomID, currentUser.id, message);
    _message = '';
    notifyListeners();
  }

  @override
  void dispose() {
    textFieldFocus.dispose();
    super.dispose();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
