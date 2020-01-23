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

    _showNewTribeDialog() {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.all(0.0),
          backgroundColor: Constants.backgroundColor,
          content: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.topLeft,
            child: NewTribe(),
          ),
        ),
      );
    }

    return currentUser != null
        ? Scaffold(
            extendBody: true,
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
                                      onTap: () => _showNewTribeDialog(),
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
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 0),
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
                Positioned(
                  bottom: 80.0,
                  child: Row(
                    children: <Widget>[
                      ButtonTheme(
                        height: 50.0,
                        child: RaisedButton.icon(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: DynamicTheme.of(context).data.primaryColor,
                          icon: Icon(Icons.library_add,
                              color: DynamicTheme.of(context).data.accentColor),
                          label: Text('Add new Tribe'),
                          textColor: Colors.white,
                          onPressed: () => _showNewTribeDialog(),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      ButtonTheme(
                        height: 50.0,
                        child: RaisedButton.icon(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: DynamicTheme.of(context).data.primaryColor,
                          icon: Icon(Icons.group_add,
                              color: DynamicTheme.of(context).data.accentColor),
                          label: Text('Join a Tribe'),
                          textColor: Colors.white,
                          onPressed: () {
                            Fluttertoast.showToast(
                                msg: 'Pressed "Join a Tribe" button',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIos: 1,
                                backgroundColor:
                                    Color(0xFF242424).withOpacity(0.9),
                                textColor: Colors.white,
                                fontSize: 16.0);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Loading();
  }

  @override
  bool get wantKeepAlive => true;
}
