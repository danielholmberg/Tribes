import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/profile/widgets/PostTileCompact.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/Loading.dart';

class CreatedPosts extends StatefulWidget {
  final UserData user;
  final bool viewOnly;
  CreatedPosts({@required this.user, this.viewOnly = false});

  @override
  _CreatedPostsState createState() => _CreatedPostsState();
}

class _CreatedPostsState extends State<CreatedPosts> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: StaggeredGridView.countBuilder(
        itemCount: widget.user.createdPosts.length,
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
            stream: DatabaseService().post(widget.user.uid, widget.user.createdPosts[index]),
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