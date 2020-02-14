import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/JoinTribe.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/NewTribe.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/TribeTile.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class Tribes extends StatefulWidget {
  @override
  _TribesState createState() => _TribesState();
}

class _TribesState extends State<Tribes> with AutomaticKeepAliveClientMixin {
  final PageController tribeController = PageController(
    viewportFraction: 0.8,
  );

  var debugList = [Colors.blue, Colors.red];

  // Keep track of current page to avoid unnecessary renders
  int currentPage = 0;

  @override
  void initState() {
    tribeController.addListener(() {
      int next = tribeController.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    tribeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Tribes()...');
    print('Current user ${currentUser.toString()}');

    _showNewTribePage() {
      Navigator.push(context, CustomPageTransition(
        type: CustomPageTransitionType.newTribe,
        duration: Constants.pageTransition800,
        child: StreamProvider<UserData>.value(
          value: DatabaseService().currentUser(currentUser.uid), 
          child: NewTribe()
        ),
      ));
    }

    _showJoinTribePage() {
      Navigator.push(context, CustomPageTransition(
        type: CustomPageTransitionType.joinTribe,
        duration: Constants.pageTransition300,
        child: StreamProvider<UserData>.value(
          value: DatabaseService().currentUser(currentUser.uid), 
          child: JoinTribe(),
        ),
      ));
    }

    return currentUser == null ? Loading()
    : Container(
      color: DynamicTheme.of(context).data.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: DynamicTheme.of(context).data.backgroundColor,
          extendBody: true,
          body: StreamBuilder<List<Tribe>>(
            initialData: [],
            stream: DatabaseService().joinedTribes(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Tribe> joinedTribesList = snapshot.data;

                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned.fill(
                      child: ScrollConfiguration(
                        behavior: CustomScrollBehavior(),
                        child: joinedTribesList.isEmpty
                        ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => _showNewTribePage(),
                                child: Text(
                                  'Create',
                                  style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 24.0,
                                      fontFamily: 'TribesRounded',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                ' or ',
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 24.0,
                                    fontFamily: 'TribesRounded',
                                    fontWeight: FontWeight.normal),
                              ),
                              GestureDetector(
                                onTap: () => _showJoinTribePage(),
                                child: Text(
                                  'Join',
                                  style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 24.0,
                                      fontFamily: 'TribesRounded',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                ' a Tribe',
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 24.0,
                                    fontFamily: 'TribesRounded',
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: PageView.builder(
                            reverse: false,
                            scrollDirection: Axis.horizontal,
                            controller: tribeController,
                            itemCount: joinedTribesList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.2),
                                child: TribeTile(tribe: joinedTribesList[index]),
                              );
                            },
                          ),
                      ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: DynamicTheme.of(context).data.primaryColor,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 5),
                            ),
                          ]
                        ),
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
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget> [
                                  IconButton(
                                    icon: Icon(Icons.add_to_photos, color: Colors.white),
                                    iconSize: Constants.defaultIconSize,
                                    onPressed: () => _showNewTribePage(),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget> [
                                  IconButton(
                                    icon: Icon(Icons.group_add, color: Colors.white),
                                    iconSize: Constants.defaultIconSize,
                                    onPressed: () => _showJoinTribePage(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
                } else {
                return Loading();
              }
            } 
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
