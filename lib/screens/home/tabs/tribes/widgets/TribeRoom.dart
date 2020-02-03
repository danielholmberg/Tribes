import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/NewPost.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/Posts.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/TribeSettings.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomPageTransition.dart';
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
      body: Container(
        color: currentTribe.color.withOpacity(0.2) ?? DynamicTheme.of(context).data.backgroundColor,
        child: StreamBuilder<User>(
          stream: AuthService().user,
          builder: (context, snapshot) {
            bool isFounder = snapshot.hasData ? snapshot.data.uid == currentTribe.founder : false;

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
                      flexibleSpace: Center(
                        child: Card(
                          color: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)
                          ),
                          margin: EdgeInsets.fromLTRB(16, 142, 16, 16),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              currentTribe.desc,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
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
                                Navigator.push(context, CustomPageTransition(
                                  type: CustomPageTransitionType.newPost,
                                  duration: Constants.pageTransition800,
                                  child: NewPost(tribe: currentTribe)
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
            );
          }
        ),
      ),
    );
  }
}
