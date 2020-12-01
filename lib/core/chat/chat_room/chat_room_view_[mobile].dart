part of chat_room_view;

class _ChatRoomViewMobile extends ViewModelWidget<ChatRoomViewModel> {
  @override
  Widget build(BuildContext context, ChatRoomViewModel model) {
    ThemeData themeData = Theme.of(context);

    _buildAppBar() {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(UtilService().isIOS
              ? FontAwesomeIcons.chevronLeft
              : FontAwesomeIcons.arrowLeft),
          color: Constants.buttonIconColor,
          onPressed: model.onExitPress,
        ),
        title: model.members != null
            ? StreamBuilder<MyUser>(
                stream: model.friendDataStream,
                builder: (context, snapshot) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Visibility(
                        visible: snapshot.hasData,
                        child: UserAvatar(
                          currentUserID: model.currentUser.id,
                          user: snapshot.data,
                          color: Colors.white,
                          radius: 14,
                          onlyAvatar: true,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                      ),
                      AutoSizeText(
                        snapshot.hasData ? snapshot.data.username : 'No name',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minFontSize: 10.0,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'TribesRounded',
                        ),
                      ),
                    ],
                  );
                })
            : AutoSizeText(
                model.currentTribe != null
                    ? model.currentTribe.name
                    : 'No name',
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 10.0,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TribesRounded',
                ),
              ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.ellipsisH),
            iconSize: Constants.defaultIconSize,
            color: Colors.white,
            onPressed: () => Fluttertoast.showToast(
              msg: 'Coming soon!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            ),
          ),
        ],
      );
    }

    _buildMessageComposer() {
      return Container(
        constraints: BoxConstraints(minHeight: 70),
        padding: EdgeInsets.only(
          top: 8.0,
          bottom: UtilService().isIOS
              ? (model.textFieldFocus.hasFocus ? 8.0 : 24.0)
              : 8.0,
        ),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.paperclip),
              iconSize: Constants.defaultIconSize,
              color: model.currentTribe != null
                  ? model.currentTribe.color
                  : themeData.primaryColor,
              onPressed: model.onAddAttachment,
            ),
            Expanded(
              child: TextField(
                focusNode: model.textFieldFocus,
                controller: model.controller,
                autofocus: model.reply != null ? model.reply : false,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 10,
                cursorRadius: Radius.circular(1000),
                cursorColor: model.currentTribe != null
                    ? model.currentTribe.color
                    : themeData.primaryColor,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                        color: model.currentTribe != null
                            ? model.currentTribe.color
                            : themeData.primaryColor,
                        width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.2), width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: model.currentTribeColor,
                      width: 2.0,
                    ),
                  ),
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    fontFamily: 'TribesRounded',
                  ),
                ),
                onChanged: model.onMessageChanged,
              ),
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.solidPaperPlane),
              iconSize: Constants.defaultIconSize,
              color: model.currentTribeColor,
              onPressed: model.message.isEmpty
                  ? null
                  : model.onSendMessage,
            ),
          ],
        ),
      );
    }

    return Container(
      color: model.currentTribeColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: model.currentTribeColor,
          appBar: _buildAppBar(),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 5,
                            offset: Offset(0, 0),
                          ),
                        ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                      child: ChatMessages(
                        roomID: model.roomID,
                        color: model.currentTribeColor,
                      ),
                    ),
                  ),
                ),
                _buildMessageComposer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
