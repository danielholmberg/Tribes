import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/profile/widgets/PostTileCompact.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class LikedPosts extends StatefulWidget {
  @override
  _LikedPostsState createState() => _LikedPostsState();
}

class _LikedPostsState extends State<LikedPosts> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building LikedPosts()...');
    print('Current user ${currentUser.uid}');

    return Container(
      padding: EdgeInsets.all(4.0),
      child: StaggeredGridView.countBuilder(
        itemCount: currentUser.likedPosts.length,
        staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
        crossAxisCount: 4,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: EdgeInsets.only(bottom: 80.0),
        itemBuilder: (context, index) {
          return StreamBuilder<Post>(
            stream: DatabaseService().post(currentUser.uid, currentUser.likedPosts[index]),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                Post likedPost = snapshot.data;
                return PostTileCompact(post: likedPost);
              } else if(snapshot.hasError) {
                return Container(padding: EdgeInsets.all(16), child: Center(child: Icon(Icons.error)));
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