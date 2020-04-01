import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/NewPost.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/PostTile.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class Posts extends StatelessWidget {
  final Tribe tribe;
  final double height;
  Posts({@required this.tribe, this.height});

  final ScrollController controller = new ScrollController();
  
  final _postsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Posts()...');
    print('Current user ${currentUser.toString()}');
    print('Tribe id: ${tribe.id}');

    return Container(
      key: _postsKey,
      child: FirestoreAnimatedList(
        controller: controller,
        padding: EdgeInsets.only(top: Constants.defaultPadding, bottom: Platform.isIOS ? 94.0 : 86.0),
        query: DatabaseService().posts(tribe.id),
        onLoaded: (snapshot) => currentUser != null 
        ? ((snapshot.documentChanges.first.type == DocumentChangeType.added && snapshot.documents.first.data['author'] == currentUser.uid) 
          ? controller.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeIn) 
          : null)
        : null,
        itemBuilder: (
          BuildContext context,
          DocumentSnapshot snapshot,
          Animation<double> animation,
          int index,
        ) =>
            FadeTransition(
          opacity: animation,
          child: PostTile(Post.fromSnapshot(snapshot), tribe.color),
        ),
        emptyChild: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Be the first to',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 18.0,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.normal
                ),
              ),
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isDismissible: false,
                  isScrollControlled: true,
                  builder: (buildContext) {
                    RenderBox postsContainer = _postsKey.currentContext.findRenderObject();
                    double postsHeight = postsContainer.size.height;
                    return StreamProvider<UserData>.value(
                      value: DatabaseService().currentUser(currentUser.uid), 
                      child: Container(
                        height: postsHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                          child: NewPost(tribe: tribe),
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
                ),
                child: Text(' add a post',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20.0,
                    fontFamily: 'TribesRounded',
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
