library new_tribe_view;


import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/tribe/new_tribe/new_tribe_view_model.dart';
import 'package:tribes/services/util_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_button.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'new_tribe_view_[mobile].dart';

class NewTribeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NewTribeViewModel>.reactive(
      viewModelBuilder: () => NewTribeViewModel(),
      onModelReady: (model) => model.initState(context: context),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _NewTribeViewMobile(),
        );
      },
    );
  }
}
