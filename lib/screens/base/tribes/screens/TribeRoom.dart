import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/tribes/dialogs/TribeDetailsDialog.dart';
import 'package:tribes/screens/base/tribes/screens/EditPost.dart';
import 'package:tribes/screens/base/tribes/screens/NewPost.dart';
import 'package:tribes/screens/base/tribes/widgets/Posts.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class TribeRoom extends StatefulWidget {
  final String tribeID;
  TribeRoom({@required this.tribeID});

  @override
  _TribeRoomState createState() => _TribeRoomState();
}

class _TribeRoomState extends State<TribeRoom> {
  final _postsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building TribeRoom()...');
    print('Current user ${currentUser.toString()}');

    double _calculatePostsHeight() {
      RenderBox postsContainer = _postsKey.currentContext.findRenderObject();
      return postsContainer.size.height;
    }

    _showModalBottomSheet({Widget child}) {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        builder: (buildContext) {
          return StreamProvider<UserData>.value(
            value: DatabaseService().currentUser(currentUser.uid), 
            child: Container(
              height: _calculatePostsHeight(),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: child,
              ),
            ),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 8.0
      );
    }

    _buildAppBar(Tribe currentTribe) {
      return Container(
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
              ],
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => StreamProvider<UserData>.value(
                      value: DatabaseService().currentUser(currentUser.uid), 
                      child: TribeDetailsDialog(tribe: currentTribe),
                    ),
                ),
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
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black45
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                IconButton(
                  icon: CustomAwesomeIcon(icon: FontAwesomeIcons.edit), 
                  splashColor: Colors.transparent,
                  onPressed: () {
                    _showModalBottomSheet(child: NewPost(tribe: currentTribe));
                  }
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    return StreamBuilder<Tribe>(
      stream: DatabaseService().tribe(widget.tribeID),
      builder: (context, snapshot) {
        final Tribe currentTribe = snapshot.hasData ? snapshot.data : null;

        return currentUser == null || currentTribe == null ? Loading()
        : Container(
          color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
          child: SafeArea(
            bottom: false,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
              body: Container(
                color: currentTribe.color.withOpacity(0.2) ?? DynamicTheme.of(context).data.backgroundColor,
                child: Column(
                  children: <Widget>[
                    _buildAppBar(currentTribe),
                    Expanded(
                      child: Container(
                        key: _postsKey,
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
                              child: Posts(
                                tribe: currentTribe,
                                onEditPostPress: (Post post) => _showModalBottomSheet(
                                  child: EditPost(post: post, tribeColor: currentTribe.color),
                                ), 
                                onEmptyTextPress: () => _showModalBottomSheet(
                                  child: NewPost(tribe: currentTribe),
                                ),
                              ),
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
