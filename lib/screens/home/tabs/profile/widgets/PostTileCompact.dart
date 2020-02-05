import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/screens/PostRoom.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/PostTile.dart';

class PostTileCompact extends StatelessWidget {
  final Post post;
  PostTileCompact({this.post});

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Profile()...');
    print('Current user ${currentUser.uid}');

    return PostTile(
      post: post,
      tribeColor: DynamicTheme.of(context).data.primaryColor,
      index: 0,
    );
  }
}
