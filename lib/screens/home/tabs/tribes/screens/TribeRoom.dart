import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/NewPost.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/Posts.dart';
import 'package:tribes/screens/home/tabs/tribes/dialogs/TribeSettings.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/utils.dart';
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
    
    return StreamBuilder<Tribe>(
      stream: DatabaseService().tribe(widget.tribeID),
      builder: (context, snapshot) {
        final Tribe currentTribe = snapshot.hasData ? snapshot.data : null;
        bool isFounder = currentTribe != null ? currentUser.uid == currentTribe.founder : false;

        return currentUser == null || currentTribe == null ? Loading()
        : Container(
          color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: DynamicTheme.of(context).data.backgroundColor,
              extendBody: true,
              body: Container(
                color: currentTribe.color.withOpacity(0.2) ?? DynamicTheme.of(context).data.backgroundColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned.fill(
                      child: ScrollConfiguration(
                        behavior: CustomScrollBehavior(),
                        child: StreamProvider<UserData>.value(
                          value: DatabaseService().currentUser(currentUser.uid),
                          child: Posts(tribe: currentTribe)
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
                          color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 5),
                            ),
                          ]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget> [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget> [
                                IconButton(icon: Icon(Icons.home), 
                                  color: Constants.buttonIconColor,
                                  splashColor: Colors.transparent,
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                Visibility(
                                  visible: isFounder,
                                  child: IconButton(
                                    icon: Icon(Icons.settings),
                                    iconSize: Constants.defaultIconSize,
                                    enableFeedback: false,
                                    splashColor: Colors.transparent,
                                    color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                    onPressed: () => null,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: AutoSizeText(
                                currentTribe.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                minFontSize: 18,
                                maxFontSize: 20,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'TribesRounded',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget> [
                                Visibility(
                                  visible: isFounder,
                                  child: IconButton(
                                    icon: Icon(Icons.settings),
                                    iconSize: Constants.defaultIconSize,
                                    splashColor: Colors.transparent,
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
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.info, color: Constants.buttonIconColor), 
                                  iconSize: Constants.defaultIconSize,
                                  splashColor: Colors.transparent,
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
                                                                  return userAvatar(snapshot.data, color: currentTribe.color);
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
                                                          onTap: () {
                                                            if(isFounder) {
                                                              showDialog(
                                                                context: context,
                                                                builder: (context) {
                                                                  bool isDeleteButtonDisabled = true;

                                                                  return StatefulBuilder(
                                                                    builder: (context, setState) {
                                                                      return AlertDialog(
                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                                                                        backgroundColor: Constants.profileSettingsBackgroundColor,
                                                                        title: Text('Leaving Tribe', style: TextStyle(fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                                                                        content: Container(
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              RichText(
                                                                                text: TextSpan(
                                                                                  text: 'As you are the founder of this Tribe, this action will permanently ',
                                                                                  style: TextStyle(color: Colors.black, fontFamily: 'TribesRounded', fontWeight: FontWeight.normal),
                                                                                  children: <TextSpan>[
                                                                                    TextSpan(text: 'DELETE', 
                                                                                      style: TextStyle(
                                                                                        color: Colors.red,
                                                                                        fontFamily: 'TribesRounded', 
                                                                                        fontWeight: FontWeight.bold
                                                                                      ),
                                                                                    ),
                                                                                    TextSpan(text: ' this Tribe and all its content. ', 
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'TribesRounded', 
                                                                                        fontWeight: FontWeight.normal
                                                                                      ),
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: 'Please type ',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'TribesRounded',
                                                                                        fontWeight: FontWeight.normal
                                                                                      ),
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: currentTribe.name,
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'TribesRounded',
                                                                                        fontWeight:FontWeight.bold
                                                                                      ),
                                                                                    ),
                                                                                    TextSpan(
                                                                                      text: ' to delete the Tribe.',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'TribesRounded',
                                                                                        fontWeight: FontWeight.normal
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              TextFormField(
                                                                                textCapitalization: TextCapitalization.words,
                                                                                decoration: Decorations.profileSettingsInput.copyWith(
                                                                                  hintText: currentTribe.name,
                                                                                ),
                                                                                onChanged: (val) {
                                                                                  if (val == currentTribe.name) {
                                                                                    setState(() => isDeleteButtonDisabled = false);
                                                                                  } else {
                                                                                    setState(() => isDeleteButtonDisabled = true);
                                                                                  }
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        actions: <Widget>[
                                                                          FlatButton(
                                                                            child: Text('Cancel', style: TextStyle(color: currentTribe.color)),
                                                                            onPressed: () {
                                                                              Navigator.of(context).pop(); // Dialog: "Please type..."
                                                                            },
                                                                          ),
                                                                          FlatButton(
                                                                            child: Text(
                                                                              'Delete',
                                                                              style: TextStyle(
                                                                                color: isDeleteButtonDisabled ? Colors.black54 : Colors.red,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            onPressed: isDeleteButtonDisabled ? null
                                                                            : () {
                                                                              DatabaseService().deleteTribe(currentTribe.id);
                                                                              Navigator.of(context).popUntil((route) => route.isFirst);
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    }
                                                                  );
                                                                }
                                                              );
                                                            } else {
                                                              showDialog(
                                                                context: context,
                                                                builder: (context) => AlertDialog(
                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                                                                  backgroundColor: Constants
                                                                      .profileSettingsBackgroundColor,
                                                                  title: Text(
                                                                      'Are your sure you want to leave this Tribe?'),
                                                                  actions: <Widget>[
                                                                    FlatButton(
                                                                      child: Text('No', 
                                                                        style: TextStyle(color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                                                      ),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                    ),
                                                                    FlatButton(
                                                                      child: Text('Yes',
                                                                        style: TextStyle(color: Colors.red),
                                                                      ),
                                                                      onPressed: () {
                                                                        DatabaseService().leaveTribe(currentUser.uid, currentTribe.id);
                                                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }
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
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Hero(
                        tag: 'NewPostButton',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(0, -5),
                              ),
                            ]
                          ),
                          child: ButtonTheme(
                            height: 60.0,
                            child: RaisedButton.icon(
                              elevation: 0.0,
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
