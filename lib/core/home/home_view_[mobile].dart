part of home_view;

class _HomeViewMobile extends ViewModelWidget<HomeViewModel> {
  @override
  Widget build(BuildContext context, HomeViewModel model) {
    final ThemeData themeData = Theme.of(context);

    _buildAppBar() {
      return AppBar(
        toolbarHeight: kToolbarHeight + Constants.largePadding,
        centerTitle: true,
        elevation: 0,
        backgroundColor: themeData.backgroundColor,
        title: Text(
          model.appTitle,
          key: model.appTitleKey,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: themeData.primaryColor,
            fontFamily: 'OleoScriptSwashCaps',
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        actions: [
          IconButton(
            icon: CustomAwesomeIcon(
              icon: FontAwesomeIcons.search,
              color: themeData.primaryColor,
            ),
            iconSize: Constants.defaultIconSize,
            splashColor: Colors.transparent,
            onPressed: model.showJoinTribePage,
          ),
          SizedBox(width: Constants.defaultPadding),
        ],
      );
    }

    _buildEmptyListWidget() {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: model.showNewTribePage,
              child: Text(
                'Create',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 24.0,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              ' or ',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 24.0,
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.normal,
              ),
            ),
            GestureDetector(
              onTap: model.showJoinTribePage,
              child: Text(
                'Join',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 24.0,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              ' a Tribe',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 24.0,
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    _buildTribesList() {
      return ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: StreamBuilder<List<Tribe>>(
          initialData: [],
          stream: model.joinedTribes,
          builder: (context, snapshot) {
            List<Tribe> joinedTribes = snapshot.data;

            return joinedTribes.isEmpty
                ? _buildEmptyListWidget()
                : PageView.builder(
                    reverse: false,
                    scrollDirection: Axis.horizontal,
                    controller: model.tribeItemController,
                    itemCount: joinedTribes.length,
                    itemBuilder: (context, index) {
                      Tribe currentTribe = joinedTribes[index];
                      double padding =
                          MediaQuery.of(context).size.height * 0.08;
                      double verticalMargin = index == model.currentPageIndex
                          ? 0.0
                          : MediaQuery.of(context).size.height * 0.04;

                      return AnimatedContainer(
                        duration: Duration(milliseconds: 1000),
                        curve: Curves.easeOutQuint,
                        padding: EdgeInsets.only(
                          bottom: kBottomNavigationBarHeight + padding,
                          top: 20.0,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: verticalMargin,
                        ),
                        child: GestureDetector(
                          onTap: () => model.showTribeRoom(
                            joinedTribes[index],
                          ),
                          child: TribeItem(tribe: currentTribe),
                        ),
                      );
                    },
                  );
          },
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: themeData.backgroundColor,
        appBar: _buildAppBar(),
        body: model.isBusy
            ? Loading()
            : Column(
                children: <Widget>[
                  Expanded(
                    child: _buildTribesList(),
                  ),
                ],
              ),
      ),
    );
  }
}
