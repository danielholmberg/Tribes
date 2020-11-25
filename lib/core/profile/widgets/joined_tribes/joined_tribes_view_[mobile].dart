part of joined_tribes_view;

class _JoinedTribesViewMobile extends ViewModelWidget<JoinedTribesViewModel> {
  @override
  Widget build(BuildContext context, JoinedTribesViewModel model) {
    ThemeData themeData = Theme.of(context);

    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: StreamBuilder<List<Tribe>>(
        initialData: [],
        stream: model.joinedTribes,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            List<Tribe> joinedTribes = snapshot.data;
            
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      Constants.defaultPadding,
                      56,
                      Constants.defaultPadding,
                      80),
                    itemCount: joinedTribes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, i) {
                      Tribe currentTribe = joinedTribes[i];
                      return GestureDetector(
                        onTap: () => showDialog(
                          context: context, 
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                            contentPadding: EdgeInsets.zero,
                            content: Container(
                              height: MediaQuery.of(context).size.height * 0.7,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: TribeItem(tribe: currentTribe),
                            ),
                          ),
                        ),
                        child: TribeItemCompact(tribe: currentTribe),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Constants.largePadding,
                    Constants.mediumPadding,
                    Constants.largePadding,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton.icon(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1000.0)
                        ),
                        color: themeData.primaryColor,
                        icon: CustomAwesomeIcon(icon: FontAwesomeIcons.plus, color: Colors.white, size: Constants.smallIconSize),
                        label: Text('Create'),
                        textColor: Colors.white,
                        onPressed: model.showNewTribePage,
                      ),
                      RaisedButton.icon(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1000.0)
                        ),
                        color: Constants.primaryColor,
                        icon: CustomAwesomeIcon(icon: FontAwesomeIcons.search, color: Colors.white, size: Constants.smallIconSize),
                        label: Text('Join'),
                        textColor: Colors.white,
                        onPressed: model.showJoinTribePage,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if(snapshot.hasError) {
            return Container(padding: EdgeInsets.all(16), child: Center(child: Icon(FontAwesomeIcons.exclamationCircle)));
          } else {
            return Loading();
          }
        }
      ),
    );
  }
}