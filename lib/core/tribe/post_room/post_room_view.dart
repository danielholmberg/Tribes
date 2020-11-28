library post_room_view;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/tribe/edit_post/edit_post_view.dart';
import 'package:tribes/core/tribe/post_room/post_room_view_model.dart';
import 'package:tribes/core/tribe/widgets/fullscreen_carousel.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/like_button.dart';
import 'package:tribes/shared/widgets/posted_date_time.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

part 'post_room_view_[mobile].dart';

class PostRoomView extends StatefulWidget {
  final Post post;
  final Color tribeColor;
  final int initialImage;
  final bool showTextContent;
  final Function onEditPostPress;
  PostRoomView({
    @required this.post,
    this.tribeColor = Constants.primaryColor,
    this.initialImage = 0,
    this.showTextContent = false,
    this.onEditPostPress,
  });

  @override
  _PostRoomViewState createState() => _PostRoomViewState();
}

class _PostRoomViewState extends State<PostRoomView>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PostRoomViewModel>.reactive(
      viewModelBuilder: () => PostRoomViewModel(),
      onModelReady: (model) => model.initState(
        post: widget.post,
        tribeColor: widget.tribeColor,
        initialImage: widget.initialImage,
        showTextContent: widget.showTextContent,
        onEditPostPress: widget.onEditPostPress,
        vsync: this,
        isMounted: this.mounted,
      ),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _PostRoomViewMobile(),
        );
      },
    );
  }
}
