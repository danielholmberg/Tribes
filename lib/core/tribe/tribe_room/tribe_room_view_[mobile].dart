part of tribe_room_view;

class _TribeRoomViewMobile extends ViewModelWidget<TribeRoomViewModel> {
  @override
  Widget build(BuildContext context, TribeRoomViewModel model) {
    final ThemeData themeData = Theme.of(context);

    _showModalBottomSheet({Widget child}) {
      showModalBottomSheet(
          context: context,
          isDismissible: false,
          isScrollControlled: true,
          builder: (buildContext) {
            return Container(
              height: model.calculatePostsHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: child,
              ),
            );
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 8.0);
    }

    _buildAppBar(Tribe currentTribe) {
      return Container(
        padding: const EdgeInsets.all(4.0),
        color: currentTribe.color ?? themeData.primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: CustomAwesomeIcon(icon: FontAwesomeIcons.home),
                  splashColor: Colors.transparent,
                  onPressed: model.onHomePress,
                ),
              ],
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(Constants.dialogCornerRadius),
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    content: ViewModelBuilder<TribeDetailsViewModel>.reactive(
                        viewModelBuilder: () => TribeDetailsViewModel(),
                        onModelReady: (model) => model.initState(
                              tribe: currentTribe,
                            ),
                        builder: (context, model, child) {
                          return TribeDetailsView();
                        }),
                  ),
                ),
                child: AutoSizeText(
                  currentTribe.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 18,
                  maxFontSize: 20,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TribesRounded',
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: CustomAwesomeIcon(icon: FontAwesomeIcons.edit),
                  splashColor: Colors.transparent,
                  onPressed: () {
                    _showModalBottomSheet(
                      child: NewPostView(tribe: currentTribe),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: model.onWillPop,
      child: StreamBuilder<Tribe>(
        stream: model.tribeStream,
        builder: (context, snapshot) {
          final Tribe currentTribe = snapshot.hasData ? snapshot.data : null;

          return Container(
            color: currentTribe.color ?? themeData.primaryColor,
            child: SafeArea(
              bottom: false,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: currentTribe != null
                    ? currentTribe.color
                    : themeData.primaryColor,
                body: currentTribe == null
                    ? Loading()
                    : Container(
                        color: currentTribe.color.withOpacity(0.2) ??
                            themeData.backgroundColor,
                        child: Column(
                          children: <Widget>[
                            _buildAppBar(currentTribe),
                            Expanded(
                              child: Container(
                                key: model.postsKey,
                                decoration: BoxDecoration(
                                  color: themeData.backgroundColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 5,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                  child: ScrollConfiguration(
                                    behavior: CustomScrollBehavior(),
                                    child: PostList(
                                      tribe: currentTribe,
                                      onEditPostPress: (Post post) {
                                        return _showModalBottomSheet(
                                          child: EditPostView(
                                            post: post,
                                            tribeColor: currentTribe.color,
                                          ),
                                        );
                                      },
                                      onEmptyTextPress: () {
                                        return _showModalBottomSheet(
                                          child: NewPostView(tribe: currentTribe),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
