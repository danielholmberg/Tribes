part of join_tribe_view;

class _JoinTribeViewMobile extends ViewModelWidget<JoinTribeViewModel> {
  @override
  Widget build(BuildContext context, JoinTribeViewModel model) {
    ThemeData themeData = Theme.of(context);

    _buildAppBar() {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.all(12.0),
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Leading Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                        UtilService().isIOS
                            ? FontAwesomeIcons.chevronLeft
                            : FontAwesomeIcons.arrowLeft,
                        color: themeData.primaryColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Icon(FontAwesomeIcons.search,
                      color: Colors.black54, size: Constants.smallIconSize),
                ],
              ),

              SizedBox(width: Constants.largePadding),

              // Center Widget
              Expanded(
                child: TextField(
                  controller: model.controller,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Enter Tribe name',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontFamily: 'TribesRounded',
                      fontSize: 16,
                      color: Colors.black54.withOpacity(0.3),
                    ),
                  ),
                  onChanged: model.onSearchTextChanged,
                ),
              ),

              // Trailing Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.solidTimesCircle,
                      color: model.controller.text.isEmpty
                          ? Colors.grey
                          : themeData.primaryColor,
                    ),
                    onPressed: model.onSearchTextClearPress,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    _showPasswordDialog(Tribe activeTribe) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(Constants.dialogCornerRadius),
              ),
            ),
            contentPadding: EdgeInsets.all(0.0),
            backgroundColor: themeData.backgroundColor,
            content: PasswordView(
              activeTribe: activeTribe,
              showJoinedSnackbar: model.showJoinedSnackbar,
            ),
          );
        },
      );
    }

    _tribeTile(Tribe tribe) {
      return GestureDetector(
        onTap: () => _showPasswordDialog(tribe),
        child: TribeItemCompact(tribe: tribe),
      );
    }

    return model.isBusy
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: themeData.primaryColor,
            body: SafeArea(
              bottom: false,
              child: Container(
                color: themeData.backgroundColor,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: StreamBuilder<List<Tribe>>(
                        stream: model.notYetJoinedTribesStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            model.setTribesList(snapshot.data
                                .where((tribe) => !tribe.secret)
                                .toList());
                            model.setSecretTribesList(snapshot.data
                                .where((tribe) => tribe.secret)
                                .toList());

                            return Container(
                              child: ScrollConfiguration(
                                behavior: CustomScrollBehavior(),
                                child: model.searchResultCount != 0 ||
                                        model.controller.text.isNotEmpty
                                    ? GridView.builder(
                                        padding: model.gridPadding,
                                        itemCount: model.searchResultCount,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                        ),
                                        itemBuilder: (context, index) {
                                          return _tribeTile(
                                            model.getTribeFromSearchList(
                                              index,
                                            ),
                                          );
                                        },
                                      )
                                    : GridView.builder(
                                        padding: model.gridPadding,
                                        itemCount: model.tribesListCount,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                        ),
                                        itemBuilder: (context, index) {
                                          return _tribeTile(
                                            model.getTribeFromTribesList(
                                              index,
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            print(
                                'Error retrieving not yet joined Tribes: ${snapshot.error.toString()}');
                            return Center(
                                child: Text('Unable to retrieve Tribes'));
                          } else {
                            return Center(
                                child: Text('Unable to retrieve Tribes'));
                          }
                        },
                      ),
                    ),
                    _buildAppBar(),
                  ],
                ),
              ),
            ),
          );
  }
}
