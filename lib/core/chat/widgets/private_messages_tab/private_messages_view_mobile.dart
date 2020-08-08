part of private_messages_view;

class _PrivateMessagesViewMobile extends StatelessWidget {
  final PrivateMessagesViewModel viewModel;
  _PrivateMessagesViewMobile(this.viewModel);

  @override
  Widget build(BuildContext context) {
    _chatRoomListItem(ChatData chatData) {
      viewModel.setNotMyId(chatData.members.where((memberID) => memberID != viewModel.currentUserData.id).toList()[0]);

      return StreamBuilder<UserData>(
        stream: DatabaseService().userData(viewModel.notMyId),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            UserData reciever = snapshot.data;

            return StreamBuilder<Message>(
              stream: DatabaseService().mostRecentMessage(chatData.id),
              builder: (context, snapshot) {
                Message message;
                bool isMe = false;
                bool isNewMessage = false;

                if(snapshot.hasData) {
                  message = snapshot.data;
                  isMe = snapshot.data.senderID == viewModel.currentUserData.id;
                  isNewMessage = !isMe && message != null;
                }

                return Container(
                  padding: EdgeInsets.fromLTRB(10.0, 4.0, isNewMessage ? 6.0 : 10.0, 4.0),
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
                        onTap: () => Navigator.push(context, 
                          CustomPageTransition(
                            type: CustomPageTransitionType.chatRoom, 
                            duration: Constants.pageTransition600, 
                            child: ChatRoomView(roomID: chatData.id, members: chatData.members),
                          )
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: DynamicTheme.of(context).data.backgroundColor,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [Constants.defaultBoxShadow],
                            border: Border.all(color: DynamicTheme.of(context).data.primaryColor.withOpacity(isNewMessage ? 1.0 : 0.5), width: 2.0),
                          ),
                          margin: EdgeInsets.only(right: isMe || message == null ? 0.0 : 22.0),
                          padding: EdgeInsets.only(right: isMe || message == null ? 6.0 : 22.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                            leading: UserAvatar(
                              currentUserID: viewModel.currentUserData.id, 
                              user: reciever, 
                              color: DynamicTheme.of(context).data.primaryColor.withOpacity(isNewMessage ? 1.0 : 0.5),
                              radius: Constants.chatMessageAvatarSize, 
                              onlyAvatar: true,
                            ),
                            title: Text(reciever.username,
                              style: TextStyle(
                                fontFamily: 'TribesRounded',
                                fontWeight: FontWeight.bold
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
                                  message != null ? 
                                  TextSpan(
                                    text: message.message ?? '',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'TribesRounded',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ) :
                                  TextSpan(
                                    text:'No messages',
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(message != null ? message.formattedTime() : '',
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
                            heroTag: 'replyButton-${reciever.id}',
                            elevation: 4.0,
                            mini: true,
                            child: CustomAwesomeIcon(icon: FontAwesomeIcons.reply, size: Constants.smallIconSize),
                            backgroundColor: DynamicTheme.of(context).data.primaryColor,
                            onPressed: () => Navigator.push(context, 
                              CustomPageTransition(
                                type: CustomPageTransitionType.chatRoom, 
                                duration: Constants.pageTransition600, 
                                child: ChatRoomView(roomID: chatData.id, members: chatData.members, reply: true),
                              )
                            ),
                          ),
                        ),
                      ),
                    ]
                  )
                );
              }
            );
          } else if(snapshot.hasError) {
            print('Error retrieving user data: ${snapshot.error.toString()}');
            return Center(child: Loading());
          } else {
            return Center(child: Loading());
          }
        }
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
          padding: EdgeInsets.only(top: 8.0, bottom: 72.0),
          reverse: false,
          shrinkWrap: true,
          query: DatabaseService().privateChatRooms(viewModel.currentUserData.id),
          itemBuilder: (
            BuildContext context,
            DocumentSnapshot snapshot,
            Animation<double> animation,
            int index,
          ) => FadeTransition(
            opacity: animation,
            child: _chatRoomListItem(ChatData.fromSnapshot(snapshot)),
          ),
          emptyChild: Center(
            child: Text('No messages',
              style: TextStyle(
                fontFamily: 'TribesRounded',
                color: Colors.black26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}