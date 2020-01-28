import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/NewTribe.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/TribeTile.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class Tribes extends StatefulWidget {
  @override
  _TribesState createState() => _TribesState();
}

class _TribesState extends State<Tribes> with AutomaticKeepAliveClientMixin {
  final PageController tribeController = PageController(
    viewportFraction: 0.7,
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
        child: NewTribe()
      ));
    }

    return currentUser != null
        ? Scaffold(
            extendBody: true,
            appBar: AppBar(
              backgroundColor: DynamicTheme.of(context).data.primaryColor,
              centerTitle: true,
              title: Text('TRIBE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              actions: <Widget>[
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      textStyle: TextStyle(color: Colors.black),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.library_add, color: Colors.black),
                          SizedBox(width: Constants.mediumPadding),
                          Text('Add new Tribe'),
                        ],
                      ),
                      value: 1,
                    ),
                    PopupMenuItem(
                      textStyle: TextStyle(color: Colors.black),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.group_add, color: Colors.black),
                          SizedBox(width: Constants.mediumPadding),
                          Text('Join a Tribe'),
                        ],
                      ),
                      value: 2,
                    )
                  ],
                  onSelected: (value) {
                    switch(value) {
                      case 1: return _showNewTribePage();
                      case 2: 
                    }
                  },
                ),
              ],
            ),
            body: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                StreamBuilder<List<Tribe>>(
                  initialData: [],
                  stream: DatabaseService().joinedTribes(currentUser.uid),
                  builder: (context, snapshot) {
                    print('Tribes snapshot $snapshot');

                    if (snapshot.hasData) {
                      var joinedTribesList = snapshot.data;
                      print('JoinedTribesList: $joinedTribesList');

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
                                //color: debugList[index],
                                padding: EdgeInsets.fromLTRB(
                                    0, 0, 0, 72),
                                child: TribeTile(
                                    tribe: joinedTribesList[index],
                                    active: index == currentPage),
                              );
                            },
                          );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
              ],
            ),
          )
        : Loading();
  }

  @override
  bool get wantKeepAlive => true;
}
