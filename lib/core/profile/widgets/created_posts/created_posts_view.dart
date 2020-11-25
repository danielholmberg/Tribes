library created_posts_view;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/profile/widgets/created_posts/created_posts_view_model.dart';
import 'package:tribes/core/tribe/widgets/post_item_compact.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'created_posts_view_[mobile].dart';

class CreatedPosts extends StatefulWidget {
  final MyUser user;
  final bool viewOnly;
  CreatedPosts({@required this.user, this.viewOnly = false});

  @override
  _CreatedPostsState createState() => _CreatedPostsState();
}

class _CreatedPostsState extends State<CreatedPosts>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => CreatedPostsViewModel(user: widget.user, viewOnly: widget.viewOnly),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _CreatedPostsViewMobile(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
