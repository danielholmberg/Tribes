part of chat_view;

class _ChatViewMobile extends ViewModelWidget<ChatViewModel> {
  @override
  Widget build(BuildContext context, ChatViewModel model) {
    final ThemeData themeData = Theme.of(context);

    _buildCategorySelector() {
      return Container(
        height: 60.0,
        color: themeData.primaryColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: model.tabsCount,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Center(
              child: GestureDetector(
                onTap: () => model.setCurrentTab(index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    model.getTab(index),
                    style: TextStyle(
                      color: index == model.currentTabIndex
                          ? Colors.white
                          : Colors.white60,
                      fontFamily: 'TribesRounded',
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    _buildAppBar() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.search),
              iconSize: Constants.defaultIconSize,
              color: Colors.white,
              onPressed: () => Fluttertoast.showToast(
                msg: 'Coming soon!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              ),
            ).onlyDevelopment(true),
            _buildCategorySelector(),
            IconButton(
              icon: Icon(FontAwesomeIcons.commentMedical),
              iconSize: Constants.defaultIconSize,
              color: Colors.white,
              onPressed: model.onStartNewChat,
            ),
          ],
        ),
      );
    }

    return Container(
      color: themeData.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: themeData.primaryColor,
          body: Column(
            children: <Widget>[
              _buildAppBar(),
              Expanded(
                child: Container(
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
                  child: model.currentTabIndex == 0
                      ? PrivateMessagesView()
                      : TribeMessagesView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
