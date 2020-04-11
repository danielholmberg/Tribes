import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/profile/widgets/PostTileCompact.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class LikedPosts extends StatefulWidget {
  final UserData user;
  final bool viewOnly;
  LikedPosts({@required this.user, this.viewOnly = false});

  @override
  _LikedPostsState createState() => _LikedPostsState();
}

class _LikedPostsState extends State<LikedPosts> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('Building LikedPosts()...');

    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: StaggeredGridView.countBuilder(
        itemCount: widget.user.likedPosts.length,
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
        crossAxisCount: 4,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: EdgeInsets.fromLTRB(
          Constants.defaultPadding, 
          Constants.defaultPadding, 
          Constants.defaultPadding, 
          80.0
        ),
        itemBuilder: (context, index) {
          return StreamBuilder<Post>(
            stream: DatabaseService().post(widget.user.uid, widget.user.likedPosts[index]),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                Post likedPost = snapshot.data;
                return PostTileCompact(post: likedPost, viewOnly: widget.viewOnly);
              } else if(snapshot.hasError) {
                return Container(padding: EdgeInsets.all(16), child: Center(child: Icon(FontAwesomeIcons.exclamationCircle)));
              } else {
                return Loading();
              }
            }
          );
        }, 
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}