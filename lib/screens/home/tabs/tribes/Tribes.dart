import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
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

    return currentUser == null ? Loading()
        : Scaffold(
          backgroundColor: DynamicTheme.of(context).data.primaryColor,
          body: ScrollConfiguration(
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
                      'TRIBES',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TribesRounded',
                        fontSize: 24,
                        letterSpacing: 8.0,
                      ),
                    ),
                    iconTheme: IconThemeData(color: Constants.buttonIconColor),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.group_add),
                        iconSize: Constants.defaultIconSize,
                        onPressed: () => print('Join Tribe clicked!'),
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
                child: StreamBuilder<List<Tribe>>(
                  initialData: [],
                  stream: DatabaseService().joinedTribes(currentUser.uid),
                  builder: (context, snapshot) {
                    //print('Tribes snapshot $snapshot');

                    if (snapshot.hasData) {
                      var joinedTribesList = snapshot.data;
                      //print('JoinedTribesList: $joinedTribesList');

                      return joinedTribesList.isEmpty
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
                                  onTap: () => Fluttertoast.showToast(
                                      msg: 'Pressed "Join" Tribe',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIos: 1,
                                      backgroundColor: Color(0xFF242424)
                                          .withOpacity(0.9),
                                      textColor: Colors.white,
                                      fontSize: 16.0),
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
                          );
                  } else {
                    return Loading();
                  }
                }),
              ),
            ),
          ),
        );
  }

  @override
  bool get wantKeepAlive => true;
}
