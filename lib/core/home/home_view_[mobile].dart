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
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              tileMode: TileMode.decal,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                themeData.backgroundColor,
                themeData.backgroundColor.withOpacity(0)
              ],
            ),
          ),
        ),
        title: GestureDetector(
          onTap: model.toggleGridLayout,
          child: Text(
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
      return StreamBuilder<List<Tribe>>(
        initialData: [],
        stream: model.stream,
        builder: (context, snapshot) {
          if (model.joinedTribes == null || model.joinedTribes.isEmpty) {
            return _buildEmptyListWidget();
          }

          _onReorder(int oldIndex, int newIndex) async {
            print('onReorder: $oldIndex : $newIndex');

            if (oldIndex != newIndex) {
              model.setCurrentDragTargetIndex(null);
            }

            Tribe row = model.joinedTribes.removeAt(oldIndex);
            model.joinedTribes.insert(newIndex, row);
            await model.saveTribeListOrder(model.joinedTribes);
          }

          _onWillAccept(int oldIndex, int newIndex) {
            print('onWillAccept: $oldIndex : $newIndex');
            if (oldIndex != newIndex) {
              model.setCurrentDragTargetIndex(newIndex);
            } else {
              model.setCurrentDragTargetIndex(null);
            }
            return true;
          }

          return ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: DragAndDropGridView(
              controller: new ScrollController(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: model.gridHasMultipleColumns ? 2 : 1,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              padding: const EdgeInsets.fromLTRB(
                16,
                kToolbarHeight + Constants.largePadding,
                16,
                kBottomNavigationBarHeight + 24,
              ),
              itemCount: model.joinedTribes.length,
              itemBuilder: (context, index) {
                Tribe tribe = model.joinedTribes[index];
                return LayoutBuilder(
                  builder: (context, costrains) {
                    if (!model.hasUpdatedTribeItemSize) {
                      model.tribeItemHeight = costrains.maxHeight;
                      model.tribeItemWidth = costrains.maxWidth;
                      model.hasUpdatedTribeItemSize = true;
                    }
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: model.currentDragTargetIndex != null ? model.currentDragTargetIndex == index ? 0.4 : 1 : 1,
                      child: Container(
                        width: model.tribeItemWidth,
                        height: model.tribeItemHeight,
                        child: GestureDetector(
                          onTap: () => model.showTribeRoom(
                            tribe,
                          ),
                          child: TribeItem(tribe: tribe),
                        ),
                      ),
                    );
                  }
                );
              },
              onReorder: _onReorder,
              onWillAccept: _onWillAccept,
            ),
          );
        },
      );
    }

    return SafeArea(
      bottom: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: themeData.backgroundColor,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: model.isBusy ? Loading() : _buildTribesList(),
      ),
    );
  }
}
