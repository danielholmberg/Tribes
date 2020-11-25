import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/core/tribe/widgets/post_item_compact.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

class LikedPosts extends StatefulWidget {
  final MyUser user;
  final bool viewOnly;
  LikedPosts({@required this.user, this.viewOnly = false});

  @override
  _LikedPostsState createState() => _LikedPostsState();
}

class _LikedPostsState extends State<LikedPosts> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<String> likedPosts = widget.user.likedPosts.reversed.toList();

    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: GridView.builder(
        itemCount: likedPosts.length,
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
            stream: DatabaseService().post(widget.user.id, likedPosts[index]),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                Post likedPost = snapshot.data;
                return PostItemCompact(post: likedPost, user: widget.user, viewOnly: widget.viewOnly);
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