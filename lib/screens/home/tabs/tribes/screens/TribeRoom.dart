import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/dialogs/TribeDetailsDialog.dart';
import 'package:tribes/screens/home/tabs/tribes/dialogs/TribeSettingsDialog.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/NewPost.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/Posts.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomButton.dart';
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
              backgroundColor: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
              body: Container(
                color: currentTribe.color.withOpacity(0.2) ?? DynamicTheme.of(context).data.backgroundColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
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
                                  IconButton(
                                    icon: CustomAwesomeIcon(icon: FontAwesomeIcons.home),
                                    splashColor: Colors.transparent,
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  Visibility(
                                    visible: isFounder,
                                    child: IconButton(
                                      icon: CustomAwesomeIcon(icon: FontAwesomeIcons.cog, color: currentTribe.color),
                                      enableFeedback: false,
                                      splashColor: Colors.transparent,
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
                                      icon: CustomAwesomeIcon(icon: FontAwesomeIcons.cog),
                                      splashColor: Colors.transparent,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => TribeSettingsDialog(tribe: currentTribe)
                                        );
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: CustomAwesomeIcon(icon: FontAwesomeIcons.infoCircle), 
                                    splashColor: Colors.transparent,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => StreamProvider<UserData>.value(
                                            value: DatabaseService().currentUser(currentUser.uid), 
                                            child: TribeDetailsDialog(tribe: currentTribe),
                                          ),
                                      );
                                    }
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: DynamicTheme.of(context).data.backgroundColor,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 5,
                                  offset: Offset(0, 0),
                                ),
                              ]
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              child: ScrollConfiguration(
                                behavior: CustomScrollBehavior(),
                                child: StreamProvider<UserData>.value(
                                  value: DatabaseService().currentUser(currentUser.uid),
                                  child: Posts(tribe: currentTribe)
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Hero(
                        tag: 'NewPostButton',
                        child: CustomButton(
                          height: 60.0,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.all(16.0),
                          icon: FontAwesomeIcons.plusCircle,
                          color: currentTribe.color,
                          iconColor: Colors.white,
                          label: Text('Add a post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
                          labelColor: Colors.white,
                          onPressed: () {
                            Navigator.push(context, CustomPageTransition(
                              type: CustomPageTransitionType.newPost,
                              duration: Duration(seconds: 1),
                              child: StreamProvider<UserData>.value(
                                value: DatabaseService().currentUser(currentUser.uid), 
                                child: NewPost(tribe: currentTribe),
                              ),
                            ));
                          },
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
