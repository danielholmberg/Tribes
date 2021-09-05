part of tribe_messages_view;

class _TribeMessagesViewMobile extends StatelessWidget {
  final TribeMessagesViewModel model;
  _TribeMessagesViewMobile(this.model);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    _buildTribeTile(Tribe currentTribe) {
      return GestureDetector(
        onTap: () => Navigator.push(context,
          CustomPageTransition(
            type: CustomPageTransitionType.chatRoom,
            duration: Constants.pageTransition300,
            child: ChatRoomView(roomID: currentTribe.id, currentTribe: currentTribe),
          )
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: currentTribe.color ?? themeData.primaryColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.black26, width: 3.0),
            boxShadow: [Constants.defaultBoxShadow],
          ),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.topCenter,
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Container(
                    color: themeData.backgroundColor,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        ChatMessages(
                          roomID: currentTribe.id,
                          color: currentTribe.color,
                          isTribePreview: true,
                        ),
                      ],
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
                    colors: [currentTribe.color, currentTribe.color.withOpacity(0.2), Colors.transparent],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: (currentTribe.color ?? themeData.primaryColor).withOpacity(0.8),
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

    return !model.dataReady ? Loading()
    : ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      ),
      child: model.hasError ? Center(child: Text('Unable to retrieve Tribes'))
      : ScrollConfiguration(
        behavior: CustomScrollBehavior(),
          child: model.joinedTribes.isNotEmpty ? GridView.builder(
            padding: EdgeInsets.only(top: 4.0, bottom: 72.0),
            itemCount: model.joinedTribes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 1.5
            ),
            itemBuilder: (context, index) {
              Tribe currentTribe = model.joinedTribes[index];
              return _buildTribeTile(currentTribe);
            },
          )
        : _buildEmptyListWidget()
      ),
    );
  }
}
