import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/NewPost.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/Posts.dart';
import 'package:tribes/screens/home/tabs/tribes/dialogs/TribeSettings.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class TribeRoom extends StatefulWidget {
  final String tribeID;
  TribeRoom({this.tribeID});

  @override
  _TribeRoomState createState() => _TribeRoomState();
}

class _TribeRoomState extends State<TribeRoom> {
  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building TribeRoom()...');
    print('Current user ${currentUser.toString()}');

    return currentUser == null ? Loading()
    : Scaffold(
      backgroundColor: DynamicTheme.of(context).data.backgroundColor,
      extendBody: true,
      body: StreamBuilder<Tribe>(
        stream: DatabaseService().tribe(widget.tribeID),
        builder: (context, snapshot) {
          final Tribe currentTribe = snapshot.hasData ? snapshot.data : null;
          bool isFounder = currentTribe != null ? currentUser.uid == currentTribe.founder : false;

          return currentTribe == null ? Loading() 
          : Container(
            color: currentTribe.color.withOpacity(0.2) ?? DynamicTheme.of(context).data.backgroundColor,
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: NestedScrollView(
                reverse: false,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      elevation: 8.0,
                      forceElevated: true,
                      backgroundColor: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                      expandedHeight: 200.0,
                      floating: false,
                      pinned: false,
                      title: AutoSizeText(
                        currentTribe.name,
                        maxLines: 1,
                        maxFontSize: 20.0,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'TribesRounded'),
                      ),
                      centerTitle: true,
                      titleSpacing: 8.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      )),
                      leading: IconButton(icon: Icon(Icons.home), 
                        color: Constants.buttonIconColor,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      actions: <Widget>[
                        isFounder 
                          ? IconButton(
                            icon: Icon(Icons.settings),
                            iconSize: Constants.defaultIconSize,
                            color: Colors.white,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                                  contentPadding: EdgeInsets.all(0.0),
                                  backgroundColor:
                                      Constants.profileSettingsBackgroundColor,
                                  content: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius)),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height * 0.8,
                                      alignment: Alignment.topLeft,
                                      child: TribeSettings(tribe: currentTribe),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ) 
                          : SizedBox.shrink(),
                        IconButton(
                          icon: Icon(Icons.sort),
                          iconSize: Constants.defaultIconSize,
                          color: Colors.white,
                          onPressed: () {
                            print('Clicked on Sort button');
                          },
                        ),
                      ],
                      flexibleSpace: Center(
                        child: Card(
                          elevation: 5.0,
                          color: DynamicTheme.of(context).data.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)
                          ),
                          margin: EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 16.0),
                          child: Container(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              currentTribe.desc,
                              style: TextStyle(
                                color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'TribesRounded',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: Container(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      StreamProvider<UserData>.value(
                        value: DatabaseService().currentUser(currentUser.uid),
                        child: Posts(tribe: currentTribe)
                      ),
                      Positioned(
                        bottom: 16.0,
                        left: 16.0,
                        right: 16.0,
                        child: Hero(
                          tag: 'NewPostButton',
                          child: ButtonTheme(
                            height: 50.0,
                            minWidth: MediaQuery.of(context).size.width,
                            child: RaisedButton.icon(
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              color: currentTribe.color ??
                                  DynamicTheme.of(context).data.primaryColor,
                              icon: Icon(Icons.library_add,
                                  color:
                                      DynamicTheme.of(context).data.accentColor),
                              label: Text('Add a post'),
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.push(context, CustomPageTransition(
                                  type: CustomPageTransitionType.newPost,
                                  duration: Constants.pageTransition800,
                                  child: StreamProvider<UserData>.value(
                                    value: DatabaseService().currentUser(currentUser.uid), 
                                    child: NewPost(tribe: currentTribe),
                                  ),
                                ));
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
