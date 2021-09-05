library edit_post_view;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/tribe/edit_post/edit_post_view_model.dart';
import 'package:tribes/core/tribe/widgets/custom_image.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_button.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/discard_changes_dialog.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'edit_post_view_[mobile].dart';

class EditPostView extends StatefulWidget {
  final Post post;
  final Color tribeColor;
  final Function(Post) onSave;
  final Function onDelete;
  EditPostView({
    @required this.post,
    this.tribeColor = Constants.primaryColor,
    this.onSave,
    this.onDelete,
  });

  @override
  _EditPostViewState createState() => _EditPostViewState();
}

class _EditPostViewState extends State<EditPostView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditPostViewModel>.reactive(
      viewModelBuilder: () => EditPostViewModel(
        tribeColor: widget.tribeColor,
        onSave: widget.onSave,
        onDelete: widget.onDelete,
      ),
      onModelReady: (model) => model.initState(
        context: context,
        isMounted: this.mounted,
        post: widget.post,
      ),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _EditPostViewMobile(),
        );
      },
    );
  }
}
