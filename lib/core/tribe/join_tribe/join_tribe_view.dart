library join_tribe_view;


import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/tribe/join_tribe/join_tribe_view_model.dart';
import 'package:tribes/core/tribe/join_tribe/widgets/password_view.dart';
import 'package:tribes/core/tribe/widgets/tribe_item_compact.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/services/util_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'join_tribe_view_[mobile].dart';

class JoinTribeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<JoinTribeViewModel>.reactive(
      viewModelBuilder: () => JoinTribeViewModel(),
      onModelReady: (model) => model.initState(context: context),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _JoinTribeViewMobile(),
        );
      },
    );
  }
}
