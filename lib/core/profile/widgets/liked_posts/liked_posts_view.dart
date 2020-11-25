library liked_posts_view;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/profile/widgets/liked_posts/liked_posts_view_model.dart';
import 'package:tribes/core/tribe/widgets/post_item_compact.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

import '../../../../locator.dart';

part 'liked_posts_view_[mobile].dart';

class LikedPosts extends StatefulWidget {
  @override
  _LikedPostsState createState() => _LikedPostsState();
}

class _LikedPostsState extends State<LikedPosts>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => LikedPostsViewModel(),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _LikedPostsMobile(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
