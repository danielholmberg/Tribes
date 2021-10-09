part of tribe_messages_view;

class _TribeMessagesViewMobile extends StatelessWidget {
  final TribeMessagesViewModel model;
  _TribeMessagesViewMobile(this.model);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    _buildEmptyChatListWidget() {
      return Center(
        child: Text(
          'Be the first to send a message',
          style: TextStyle(
            fontFamily: 'TribesRounded',
            color: Colors.black26,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    _buildTribeTile(Tribe currentTribe) {
      Widget tribeChatWidget = Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.topCenter,
          children: <Widget>[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  color: themeData.backgroundColor,
                  child: StreamBuilder<List<Message>>(
                    initialData: [],
                    stream: model.mostRecentMessagesStream(currentTribe.id, 5),
                    builder: (context, snapshot) {
                      if (!model.hasLoaded ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.zero,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            bool shouldBeOnTheLeft = index % 2 == 1;
                            bool shouldBeBigMessage = index % 3 == 1;
                            Random random = new Random();
                            int widthJitter = random.nextInt(
                                (MediaQuery.of(context).size.width * 0.2)
                                    .toInt());

                            Widget userAvatar = CircleAvatar(
                              radius: 10,
                              backgroundColor: currentTribe.color,
                            );

                            Widget message = Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: shouldBeBigMessage ? 50 : 30,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3 +
                                          widthJitter,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            );

                            return Container(
                              padding: EdgeInsets.all(
                                6.0,
                              ),
                              child: Shimmer.fromColors(
                                baseColor: currentTribe.color.withOpacity(
                                  0.05,
                                ),
                                highlightColor: currentTribe.color.withOpacity(
                                  0.2,
                                ),
                                child: shouldBeOnTheLeft
                                    ? Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          userAvatar,
                                          SizedBox(width: 6.0),
                                          message,
                                        ],
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          message,
                                          SizedBox(width: 6.0),
                                          userAvatar,
                                        ],
                                      ),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasData && snapshot.data.length > 0) {
                        return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return ChatMessageItem(
                              message: snapshot.data[index],
                              color: currentTribe.color,
                            );
                          },
                        );
                      } else {
                        return _buildEmptyChatListWidget();
                      }
                    },
                  ),
                ),
              ),
            ),
            ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.1, 0.4, 1.0],
                  colors: [
                    currentTribe.color,
                    currentTribe.color.withOpacity(0.2),
                    Colors.transparent
                  ],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8.0,
                ),
                decoration: BoxDecoration(
                  color: (currentTribe.color ?? themeData.primaryColor)
                      .withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                ),
                child: AutoSizeText(
                  currentTribe.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  minFontSize: 10.0,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TribesRounded',
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: currentTribe.color ?? themeData.primaryColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.black26, width: 3.0),
          boxShadow: [Constants.defaultBoxShadow],
        ),
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 500),
          crossFadeState: model.hasLoaded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: tribeChatWidget,
          secondChild: GestureDetector(
            onTap: () => Navigator.push(
              context,
              CustomPageTransition(
                type: CustomPageTransitionType.chatRoom,
                duration: Constants.pageTransition300,
                child: ChatRoomView(
                  roomID: currentTribe.id,
                  currentTribe: currentTribe,
                ),
              ),
            ),
            child: tribeChatWidget,
          ),
        ),
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
                    FontAwesomeIcons.search,
                    color: Colors.blueGrey.withOpacity(0.8),
                  ),
                ),
                GestureDetector(
                  onTap: model.showJoinTribePage,
                  child: Text(
                    'Join a Tribe',
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
        child: StreamBuilder<List<Tribe>>(
          initialData: null,
          stream: model.joinedTribesStream,
          builder: (context, snapshot) {
            model.onData(snapshot.data);

            if (snapshot.hasData) {
              List<Tribe> joinedTribes = snapshot.data;

              return GridView.builder(
                padding: EdgeInsets.only(top: 4.0, bottom: 72.0),
                itemCount: joinedTribes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  Tribe currentTribe = joinedTribes[index];
                  return _buildTribeTile(currentTribe);
                },
              );
            } else if (snapshot.hasError) {
              print(
                  'Error retrieving joined Tribes: ${snapshot.error.toString()}');
              return _buildEmptyListWidget();
            } else {
              return Loading();
            }
          },
        ),
      ),
    );
  }
}
