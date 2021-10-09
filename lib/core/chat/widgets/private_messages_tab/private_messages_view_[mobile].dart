part of private_messages_view;

class _PrivateMessagesViewMobile
    extends ViewModelWidget<PrivateMessagesViewModel> {
  _PrivateMessagesViewMobile();

  @override
  Widget build(BuildContext context, PrivateMessagesViewModel model) {
    ThemeData themeData = Theme.of(context);

    _buildChatRoomListItem(ChatData chatData) {
      model.setNotMyId(chatData.members
          .firstWhere((memberID) => memberID != model.currentUser.id));
      return StreamBuilder<MyUser>(
        stream: model.friendDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error retrieving user data: ${snapshot.error.toString()}');
            return Center(child: Text('Unable to retrieve private chat'));
          }

          MyUser friend = snapshot.data;

          return AnimatedCrossFade(
            duration: const Duration(milliseconds: 500),
            crossFadeState: friend != null && model.hasLoaded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 50,
                minWidth: double.infinity,
                maxHeight: MediaQuery.of(context).size.height * 0.4,
                maxWidth: double.infinity,
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  10.0,
                  4.0,
                  10.0,
                  4.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData.backgroundColor,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [Constants.defaultBoxShadow],
                    border: Border.all(
                      color: themeData.primaryColor.withOpacity(0.5),
                      width: 2.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    leading: UserAvatar(
                      user: null,
                      color: themeData.primaryColor.withOpacity(0.5),
                      radius: Constants.chatMessageAvatarSize,
                      onlyAvatar: true,
                    ),
                    title: Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: themeData.primaryColor.withOpacity(0.5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 14,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: themeData.primaryColor.withOpacity(0.5),
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor:
                              themeData.primaryColor.withOpacity(0.5),
                          child: Container(
                            height: 14,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            secondChild: friend != null
                ? StreamBuilder<Message>(
                    stream: model.getMostRecentMessageStream(chatData.id),
                    builder: (context, snapshot) {
                      Message message;
                      bool isMe = false;
                      bool isNewMessage = false;

                      if (snapshot.hasData) {
                        message = snapshot.data;
                        isMe = snapshot.data.senderID == model.currentUser.id;
                        isNewMessage = !isMe && message != null;
                      }

                      return Container(
                        padding: EdgeInsets.fromLTRB(
                          10.0,
                          4.0,
                          isNewMessage ? 6.0 : 10.0,
                          4.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => model.onPrivateChatPress(
                                chatData,
                                reply: false,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: themeData.backgroundColor,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [Constants.defaultBoxShadow],
                                  border: Border.all(
                                    color: themeData.primaryColor.withOpacity(
                                      isNewMessage ? 1.0 : 0.5,
                                    ),
                                    width: 2.0,
                                  ),
                                ),
                                margin: EdgeInsets.only(
                                  right: isMe || message == null ? 0.0 : 22.0,
                                ),
                                padding: EdgeInsets.only(
                                  right: isMe || message == null ? 6.0 : 22.0,
                                ),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  leading: UserAvatar(
                                    currentUserID: model.currentUser.id,
                                    user: friend,
                                    color: themeData.primaryColor
                                        .withOpacity(isNewMessage ? 1.0 : 0.5),
                                    radius: Constants.chatMessageAvatarSize,
                                    onlyAvatar: true,
                                  ),
                                  title: Text(
                                    friend.username,
                                    style: TextStyle(
                                      fontFamily: 'TribesRounded',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: RichText(
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                    text: TextSpan(
                                      text: '${isMe ? 'You: ' : ''}',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontFamily: 'TribesRounded',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                      children: <TextSpan>[
                                        message != null
                                            ? TextSpan(
                                                text: message.message ?? '',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: 'TribesRounded',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              )
                                            : TextSpan(
                                                text: 'Unable to load message',
                                                style: TextStyle(
                                                  fontFamily: 'TribesRounded',
                                                  color: Colors.black26,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        message != null
                                            ? message.formattedTime()
                                            : '',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: isNewMessage,
                              child: Positioned(
                                right: 0,
                                child: FloatingActionButton(
                                  heroTag: 'replyButton-${friend.id}',
                                  elevation: 4.0,
                                  mini: true,
                                  child: CustomAwesomeIcon(
                                    icon: FontAwesomeIcons.reply,
                                    size: Constants.smallIconSize,
                                  ),
                                  backgroundColor: themeData.primaryColor,
                                  onPressed: () => model.onPrivateChatPress(
                                    chatData,
                                    reply: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : SizedBox.shrink(),
          );
        },
      );
    }

    _buildEmptyListWidget() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Nothing here yet...',
              style: TextStyle(
                color: Colors.blueGrey.withOpacity(0.8),
                fontSize: 16.0,
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.normal,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    FontAwesomeIcons.commentMedical,
                    color: Colors.blueGrey.withOpacity(0.8),
                  ),
                ),
                GestureDetector(
                  onTap: model.onStartNewChat,
                  child: Text(
                    'Search for a fellow Tribe member',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey.withOpacity(0.8),
                      fontSize: 16.0,
                      fontFamily: 'TribesRounded',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              ' to start chatting right now!',
              style: TextStyle(
                color: Colors.blueGrey.withOpacity(0.8),
                fontSize: 16.0,
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: FirestoreAnimatedList(
          padding: EdgeInsets.only(top: 8.0, bottom: kBottomNavigationBarHeight + 16),
          reverse: false,
          shrinkWrap: true,
          query: model.privateChatRooms,
          onLoaded: (doc) => model.onData(),
          itemBuilder: (
            BuildContext context,
            DocumentSnapshot snapshot,
            Animation<double> animation,
            int index,
          ) {
            return FadeTransition(
              opacity: animation,
              child: _buildChatRoomListItem(
                ChatData.fromSnapshot(snapshot),
              ),
            );
          },
          defaultChild: Loading(),
          emptyChild: _buildEmptyListWidget(),
          errorChild: _buildEmptyListWidget(),
        ),
      ),
    );
  }
}
