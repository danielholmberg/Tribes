part of new_chat_view;

class _NewChatViewMobile extends ViewModelWidget<NewChatViewModel> {
  @override
  Widget build(BuildContext context, NewChatViewModel model) {
    final ThemeData themeData = Theme.of(context);

    _friendTile(MyUser friend) {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        leading: UserAvatar(
          currentUserID: model.currentUser.id,
          user: friend,
          radius: 20,
          withName: true,
          withUsername: true,
          cornerRadius: 0.0,
          color: themeData.primaryColor,
          textColor: themeData.primaryColor,
          textPadding: const EdgeInsets.only(left: 8.0),
        ),
        trailing: FloatingActionButton(
          heroTag: 'newChatButton-${friend.id}',
          elevation: 4.0,
          mini: true,
          child: CustomAwesomeIcon(
            icon: FontAwesomeIcons.pen,
            size: Constants.smallIconSize,
          ),
          backgroundColor: themeData.primaryColor,
          onPressed: () async => await model.onFriendAvatarPress(friend.id),
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeData.primaryColor,
      body: SafeArea(
        child: Container(
          color: themeData.backgroundColor,
          child: model.isBusy
              ? Loading()
              : Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: FutureBuilder<List<MyUser>>(
                        initialData: [],
                        future: model.friendsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            model.setFriendsList(snapshot.data);
                            return Container(
                              child: ScrollConfiguration(
                                behavior: CustomScrollBehavior(),
                                child: model.notEmptySearchResult ||
                                        model.controller.text.isNotEmpty
                                    ? ListView.builder(
                                        padding: model.gridPadding,
                                        itemCount: model.searchResultCount,
                                        itemBuilder: (context, index) {
                                          return _friendTile(
                                            model.getFriendFromSearch(
                                              index,
                                            ),
                                          );
                                        },
                                      )
                                    : ListView.builder(
                                        padding: model.gridPadding,
                                        itemCount: model.friendsListCount,
                                        itemBuilder: (context, index) {
                                          return _friendTile(
                                            model.getFriendFromFriends(
                                              index,
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            print(
                                'Error retrieving friends: ${snapshot.error.toString()}');
                            return Center(
                                child: Text('Unable to retrieve friends'));
                          } else {
                            return Center(child: Loading());
                          }
                        },
                      ),
                    ),
                    Align(
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
                                    color: themeData.primaryColor,
                                  ),
                                  onPressed: model.onExitPress,
                                ),
                                Icon(
                                  FontAwesomeIcons.search,
                                  color: Colors.black54,
                                  size: Constants.smallIconSize,
                                ),
                              ],
                            ),

                            SizedBox(width: Constants.largePadding),

                            // Center Widget
                            Expanded(
                              child: TextField(
                                controller: model.controller,
                                autofocus: false,
                                decoration: InputDecoration(
                                  hintText: 'Find your friend',
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
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
