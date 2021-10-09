import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/chat_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/router.dart';
import 'package:tribes/services/firebase/database_service.dart';

class NewChatViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final TextEditingController _controller = new TextEditingController();

  Future _friendsFuture;

  List<MyUser> _friendsList = [];
  List<MyUser> _searchResult = [];

  String _error = '';

  EdgeInsets get gridPadding =>
      const EdgeInsets.fromLTRB(12.0, 82.0, 12.0, 12.0);

  MyUser get currentUser => _databaseService.currentUserData;

  TextEditingController get controller => _controller;
  Future get friendsFuture => _friendsFuture;

  List<MyUser> get friendsList => _friendsList;
  int get friendsListCount => _friendsList.length;
  List<MyUser> get searchResult => _searchResult;
  int get searchResultCount => _searchResult.length;

  bool get notEmptySearchResult => _searchResult.isNotEmpty;

  void onJoinTribe() {
    _navigationService.back();
    _navigationService.navigateTo(MyRouter.joinTribeRoute);
  }

  void initState() {
    _friendsFuture = DatabaseService().friendsList(currentUser.id);
  }

  void onExitPress() {
    _navigationService.back();
  }

  Future onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      notifyListeners();
      return;
    }

    _friendsList.forEach((friend) {
      if (friend.name.toLowerCase().contains(text.toLowerCase()) ||
          friend.username.toLowerCase().contains(text.toLowerCase())) {
        _searchResult.add(friend);
      }
    });

    notifyListeners();
  }

  void onSearchTextClearPress() {
    controller.clear();
    onSearchTextChanged('');
  }

  Future onFriendAvatarPress(String friendId) async {
    setBusy(true);

    String roomID = await _databaseService.createNewPrivateChatRoom(
      friendId,
    );

    setBusy(false);
    _navigationService.navigateTo(
      MyRouter.chatRoomRoute,
      arguments: ChatRoomArguments(
        roomId: roomID,
        members: [currentUser.id, friendId],
        reply: true,
      ),
    );
  }

  void setFriendsList(List<MyUser> data) {
    _friendsList = data;
  }

  MyUser getFriendFromSearch(int index) {
    return _searchResult[index];
  }

  MyUser getFriendFromFriends(int index) {
    return _friendsList[index];
  }

  @override
  bool get hasError => _error.isNotEmpty;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
