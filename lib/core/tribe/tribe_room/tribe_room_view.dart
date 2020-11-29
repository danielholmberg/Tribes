library tribe_room_view;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/tribe/dialogs/tribe_details/tribe_details_view.dart';
import 'package:tribes/core/tribe/dialogs/tribe_details/tribe_details_view_model.dart';
import 'package:tribes/core/tribe/edit_post/edit_post_view.dart';
import 'package:tribes/core/tribe/new_post/new_post_view.dart';
import 'package:tribes/core/tribe/tribe_room/tribe_room_view_model.dart';
import 'package:tribes/core/tribe/widgets/post_list.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'tribe_room_view_[mobile].dart';

class TribeRoomView extends StatefulWidget {
  final String tribeId;
  final Color tribeColor;
  TribeRoomView({
    @required this.tribeId,
    @required this.tribeColor,
  });

  @override
  _TribeRoomViewState createState() => _TribeRoomViewState();
}

class _TribeRoomViewState extends State<TribeRoomView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TribeRoomViewModel>.reactive(
      viewModelBuilder: () => TribeRoomViewModel(
        tribeId: widget.tribeId,
        tribeColor: widget.tribeColor,
      ),
      onModelReady: (model) => model.initState(),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _TribeRoomViewMobile(),
        );
      },
    );
  }
}
