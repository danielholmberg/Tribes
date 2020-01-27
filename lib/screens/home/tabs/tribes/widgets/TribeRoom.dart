import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/NewPost.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/Posts.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/TribeSettings.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';

class TribeRoom extends StatefulWidget {
  @override
  _TribeRoomState createState() => _TribeRoomState();
}

class _TribeRoomState extends State<TribeRoom> {
  @override
  Widget build(BuildContext context) {
    Tribe currentTribe = Provider.of<Tribe>(context);

    return Scaffold(
      backgroundColor: DynamicTheme.of(context).data.backgroundColor,
      extendBody: true,
      body: StreamBuilder<User>(
        stream: AuthService().user,
        builder: (context, snapshot) {
          bool isFounder = snapshot.data.uid == currentTribe.founder;

          return ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: NestedScrollView(
              reverse: false,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    elevation: 8.0,
                    forceElevated: true,
                    backgroundColor: currentTribe.color ??
                        DynamicTheme.of(context).data.primaryColor,
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    titleSpacing: 8.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    )),
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
                                contentPadding: EdgeInsets.all(0.0),
                                backgroundColor:
                                    Constants.profileSettingsBackgroundColor,
                                content: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  alignment: Alignment.topLeft,
                                  child: TribeSettings(tribe: currentTribe),
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
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: EdgeInsets.only(bottom: 12),
                      title: AutoSizeText(
                        currentTribe.name,
                        maxLines: 1,
                        maxFontSize: 20.0,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'TribesRounded'),
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: AutoSizeText(
                          currentTribe.desc,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Posts(tribe: currentTribe),
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
                                  label: Text('Write a post'),
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Navigator.push(context, PageTransition(
                                      type: PageTransitionType.scale, 
                                      alignment: Alignment.bottomCenter,
                                      duration: Duration(milliseconds: Constants.pageTransition600),
                                      child: NewPost(tribeID: currentTribe.id))
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
