import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/animated_firestore_staggered.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/profile/widgets/PostTileCompact.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class CreatedPosts extends StatefulWidget {
  @override
  _CreatedPostsState createState() => _CreatedPostsState();
}

class _CreatedPostsState extends State<CreatedPosts> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building CreatedPosts()...');
    print('Current user ${currentUser.uid}');

    return Container(
      padding: EdgeInsets.all(4.0),
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: FirestoreAnimatedStaggered(
          staggeredTileBuilder: (int index, DocumentSnapshot snapshot) => StaggeredTile.fit(1),
          crossAxisCount: 4,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          padding: EdgeInsets.only(bottom: 80.0),
          query: DatabaseService().postsPublishedByUser(currentUser.uid),
          itemBuilder: (
            BuildContext context,
            DocumentSnapshot snapshot,
            Animation<double> animation,
            int index,
          ) =>
          FadeTransition(
            opacity: animation,
            child: Transform.scale(
              scale: Constants.postTileCompactScaleFactor,
              child: PostTileCompact(post: Post.fromSnapshot(snapshot))
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}