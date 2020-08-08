part of home_view;

class _HomeViewMobile extends StatelessWidget {
  final HomeViewModel viewModel;
  _HomeViewMobile(this.viewModel);

  @override
  Widget build(BuildContext context) {
    
    _buildAppBar() {
      return Container(
        padding: const EdgeInsets.all(4.0),
        color: DynamicTheme.of(context).data.primaryColor,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget> [
            Text(
              'Tribes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OleoScriptSwashCaps',
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget> [

                  // Join Tribe Icon Widget
                  IconButton(
                    icon: CustomAwesomeIcon(icon: FontAwesomeIcons.search),
                    iconSize: Constants.defaultIconSize,
                    splashColor: Colors.transparent,
                    onPressed: () => viewModel.showJoinTribePage(),
                  ),

                ],
              ),
            ),
          ],
        ),
      );
    }

    _buildEmptyListWidget() {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => viewModel.showNewTribePage(),
              child: Text(
                'Create',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 24.0,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Text(
              ' or ',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 24.0,
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.normal
              ),
            ),
            GestureDetector(
              onTap: () => viewModel.showJoinTribePage(),
              child: Text(
                'Join',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 24.0,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Text(
              ' a Tribe',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 24.0,
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.normal
              ),
            ),
          ],
        ),
      );
    }

    _buildTribesList() {
      return ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: viewModel.joinedTribes.isEmpty ? _buildEmptyListWidget() 
        : Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: PageView.builder(
            reverse: false,
            scrollDirection: Axis.horizontal,
            controller: viewModel.tribeItemController,
            itemCount: viewModel.joinedTribes.length,
            itemBuilder: (context, index) {
              Tribe currentTribe = viewModel.joinedTribes[index];
              double padding = MediaQuery.of(context).size.height * 0.08;
              double verticalMargin = index == viewModel.currentPage ? 0.0 : MediaQuery.of(context).size.height * 0.04;

              return AnimatedContainer(
                duration: Duration(milliseconds: 1000),
                curve: Curves.easeOutQuint,
                padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight + padding, top: padding),
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: verticalMargin),
                child: GestureDetector(
                  onTap: () => viewModel.showTribeRoom(),
                  child: TribeItem(tribe: currentTribe),
                ),
              );
            },
          ),
        ),
      );
    }

    return !viewModel.dataReady ? Loading()
    : Container(
      color: DynamicTheme.of(context).data.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: DynamicTheme.of(context).data.primaryColor,
          body: Column(
            children: <Widget>[
              _buildAppBar(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: DynamicTheme.of(context).data.backgroundColor,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      ),
                    ]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    child: _buildTribesList(),
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