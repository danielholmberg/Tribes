import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final String founderID;
  TribeRoom({this.tribeID, this.founderID});

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
                      elevation: 4.0,
                      forceElevated: true,
                      backgroundColor: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                      expandedHeight: 200.0,
                      floating: false,
                      pinned: false,
                      centerTitle: true,
                      title: Text(
                        currentTribe.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'TribesRounded',
                          fontSize: 20,
                        ),
                      ),
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
                            splashColor: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
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
                          icon: Icon(Icons.info, color: Constants.buttonIconColor), 
                          iconSize: Constants.defaultIconSize,
                          splashColor: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                                contentPadding: EdgeInsets.all(0.0),
                                backgroundColor: DynamicTheme.of(context).data.backgroundColor,
                                content: ScrollConfiguration(
                                  behavior: CustomScrollBehavior(),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius)),
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Tribe Details',
                                              style:
                                                  DynamicTheme.of(context).data.textTheme.title,
                                            ),
                                          ),
                                          SizedBox(height: Constants.defaultSpacing),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  SizedBox(width: Constants.defaultSpacing),
                                                  Expanded(child: Divider(thickness: 2.0,)),
                                                  SizedBox(width: Constants.defaultSpacing),
                                                  Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(width: Constants.defaultSpacing),
                                                  Expanded(child: Divider(thickness: 2.0,)),
                                                  SizedBox(width: Constants.defaultSpacing),
                                                ],
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width,
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
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  SizedBox(width: Constants.defaultSpacing),
                                                  Expanded(child: Divider(thickness: 2.0,)),
                                                  SizedBox(width: Constants.defaultSpacing),
                                                  Text('Chief', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(width: Constants.defaultSpacing),
                                                  Expanded(child: Divider(thickness: 2.0,)),
                                                  SizedBox(width: Constants.defaultSpacing),
                                                ],
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(12.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: <Widget>[
                                                    StreamBuilder<UserData>(
                                                      stream: DatabaseService().userData(currentTribe.founder),
                                                      builder: (context, snapshot) {

                                                        if(snapshot.hasData) {
                                                          UserData founderData = snapshot.data;
                                                          print('founderData: $founderData'); 
                                                          return Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: <Widget>[
                                                              CachedNetworkImage(
                                                                imageUrl: founderData.picURL.isNotEmpty ? founderData.picURL : 'https://picsum.photos/id/237/200/300',
                                                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                                                  radius: Constants.defaultProfilePicRadius,
                                                                  backgroundImage: imageProvider,
                                                                  backgroundColor: Colors.transparent,
                                                                ),
                                                                placeholder: (context, url) => CircleAvatar(
                                                                  radius: Constants.defaultProfilePicRadius,
                                                                  backgroundColor: Colors.transparent,
                                                                ),
                                                                errorWidget: (context, url, error) => CircleAvatar(
                                                                  radius: Constants.defaultProfilePicRadius,
                                                                  backgroundColor: Colors.transparent,
                                                                  child: Center(child: Icon(Icons.error)),
                                                                ),
                                                              ),
                                                              SizedBox(width: Constants.defaultPadding),
                                                              Text(founderData.username,
                                                                style: TextStyle(
                                                                  color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                                                  fontFamily: 'TribesRounded',
                                                                  fontWeight: FontWeight.bold
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        } else if(snapshot.hasError) {
                                                          print('Error getting founder user data: ${snapshot.error.toString()}');
                                                          return SizedBox.shrink();
                                                        } else {
                                                          return SizedBox.shrink();
                                                        }
                                                        
                                                      }
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  SizedBox(width: Constants.defaultSpacing),
                                                  Expanded(child: Divider(thickness: 2.0,)),
                                                  SizedBox(width: Constants.defaultSpacing),
                                                  Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(width: Constants.defaultSpacing),
                                                  Expanded(child: Divider(thickness: 2.0,)),
                                                  SizedBox(width: Constants.defaultSpacing),
                                                ],
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(currentTribe.password, 
                                                  style: TextStyle(
                                                    fontFamily: 'TribesRounded',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 24,
                                                    letterSpacing: 6.0,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(12.0),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    await DatabaseService().leaveTribe(currentUser.uid, currentTribe.id);
                                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                                  } ,
                                                  child: Text('Leave Tribe', 
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily: 'TribesRounded',
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(),
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
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Hero(
                          tag: 'NewPostButton',
                          child: ButtonTheme(
                            height: 60.0,
                            child: RaisedButton.icon(
                              elevation: 8.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                              ),
                              color: currentTribe.color ??
                                  DynamicTheme.of(context).data.primaryColor,
                              icon: Icon(Icons.library_add, color: DynamicTheme.of(context).data.accentColor, size: Constants.defaultIconSize),
                              label: Text('Add a post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
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
