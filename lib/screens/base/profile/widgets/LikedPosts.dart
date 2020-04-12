import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/tribes/widgets/PostTileCompact.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';

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
      child: GridView.builder(
        itemCount: widget.user.likedPosts.length,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 80.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.0,
          crossAxisCount: 3,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
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