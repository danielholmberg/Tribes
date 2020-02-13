import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

    _showJoinTribePage(List<Tribe> joinedTribes) {
      List<String> joinedTribesIDs = [];
      joinedTribes.forEach((tribe) => joinedTribesIDs.add(tribe.id));
      
      Navigator.push(context, CustomPageTransition(
        type: CustomPageTransitionType.joinTribe,
        duration: Constants.pageTransition300,
        child: StreamProvider<UserData>.value(
          value: DatabaseService().currentUser(currentUser.uid), 
          child: JoinTribe(joinedTribesIDs),
        ),
      ));
    }

    return currentUser == null ? Loading()
        : Scaffold(
          backgroundColor: DynamicTheme.of(context).data.primaryColor,
          body: SafeArea(
            bottom: false,
            child: StreamBuilder<List<Tribe>>(
              initialData: [],
              stream: DatabaseService().joinedTribes(currentUser.uid),
              builder: (context, snapshot) {

                if (snapshot.hasData) {
                  List<Tribe> joinedTribesList = snapshot.data;

                  return ScrollConfiguration(
                    behavior: CustomScrollBehavior(),
                    child: NestedScrollView(
                      reverse: false,
                      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            elevation: 0.0,
                            forceElevated: true,
                            backgroundColor: DynamicTheme.of(context).data.primaryColor,
                            floating: false,
                            pinned: false,
                            centerTitle: true,
                            title: Text(
                              'Tribes',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'OleoScriptSwashCaps',
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            iconTheme: IconThemeData(color: Constants.buttonIconColor),
                            actions: <Widget>[
                              IconButton(
                                icon: Icon(Icons.group_add),
                                iconSize: Constants.defaultIconSize,
                                onPressed: () => _showJoinTribePage(joinedTribesList),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_to_photos),
                                iconSize: Constants.defaultIconSize,
                                onPressed: () => _showNewTribePage(),
                              ),
                            ],
                          ),
                        ];
                      },
                      body: Container(
                        decoration: BoxDecoration(
                          color: DynamicTheme.of(context).data.backgroundColor,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                        ),
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
                                    onTap: () => _showJoinTribePage(joinedTribesList),
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
                          : PageView.builder(
                              reverse: true,
                              scrollDirection: Axis.vertical,
                              controller: tribeController,
                              itemCount: joinedTribesList.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 52),
                                  child: TribeTile(tribe: joinedTribesList[index]),
                                );
                              },
                            ),
                      ),
                    ),
                  );
                } else {
                  return Loading();
                }
              }
            ),
          ),
        );
  }

  @override
  bool get wantKeepAlive => true;
}
