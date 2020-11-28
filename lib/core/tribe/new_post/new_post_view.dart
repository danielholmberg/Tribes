library new_post_view;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/tribe/new_post/new_post_view_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/services/firebase/storage_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_button.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/discard_changes_dialog.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'new_post_view_[mobile].dart';

class NewPostView extends StatefulWidget {
  final Tribe tribe;
  NewPostView({@required this.tribe});

  @override
  _NewPostViewState createState() => _NewPostViewState();
}

class _NewPostViewState extends State<NewPostView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewPostViewModel>.reactive(
      viewModelBuilder: () => NewPostViewModel(),
      onModelReady: (model) => model.initState(
        tribe: widget.tribe,
        isMounted: this.mounted,
      ),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _NewPostViewMobile(),
        );
      },
    );
  }
}
