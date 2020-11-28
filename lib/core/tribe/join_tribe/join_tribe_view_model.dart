import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/services/firebase/database_service.dart';

class JoinTribeViewModel extends ReactiveViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();

  BuildContext _context;

  List<Tribe> _tribesList = [];
  List<Tribe> _secretTribesList = [];
  List<Tribe> _searchResult = [];

  TextEditingController _controller = new TextEditingController();

  EdgeInsets get gridPadding => const EdgeInsets.fromLTRB(8.0, 82.0, 8.0, 8.0);

  Stream<List<Tribe>> get notYetJoinedTribesStream =>
      _databaseService.notYetJoinedTribes;

  TextEditingController get controller => _controller;

  int get searchResultCount => _searchResult.length;
  int get tribesListCount => _tribesList.length;

  void initState({@required BuildContext context}) {
    _context = context;
  }

  Future onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      notifyListeners();
      return;
    }

    List<Tribe> searchList = _tribesList + _secretTribesList;
    searchList.forEach((tribe) {
      if (tribe.secret) {
        if (tribe.name == text) {
          _searchResult.add(tribe);
        }
      } else {
        if (tribe.name.toLowerCase().contains(text.toLowerCase())) {
          _searchResult.add(tribe);
        }
      }
    });

    notifyListeners();
  }

  void onSearchTextClearPress() {
    _controller.clear();
    onSearchTextChanged('');
  }

  void showJoinedSnackbar(Tribe joinedTribe) {
    _searchResult.clear();
    _controller.clear();
    notifyListeners();

    Future.delayed(
      Duration(milliseconds: 300),
      () => ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(
          content: RichText(
            text: TextSpan(
              text: 'Successfully joined Tribe ',
              style: TextStyle(
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.normal,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: joinedTribe.name,
                  style: TextStyle(
                    fontFamily: 'TribesRounded',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          duration: Duration(milliseconds: 1000),
        ),
      ),
    );
  }

  void setTribesList(List<Tribe> tribesList) {
    _tribesList = tribesList;
    notifyListeners();
  }

  void setSecretTribesList(List<Tribe> secretTribesList) {
    _secretTribesList = secretTribesList;
    notifyListeners();
  }

  Tribe getTribeFromSearchList(int index) => _searchResult[index];
  Tribe getTribeFromTribesList(int index) => _tribesList[index];

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}
