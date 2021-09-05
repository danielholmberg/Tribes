library foundation_view;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/foundation/foundation_view_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:tribes/shared/widgets/custom_nav_bar_item.dart';
import 'package:tribes/shared/widgets/custom_raised_button.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

part 'foundation_view_[mobile].dart';

class FoundationView extends StatefulWidget {
  @override
  _FoundationViewState createState() => _FoundationViewState();
}

class _FoundationViewState extends State<FoundationView> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FoundationViewModel>.reactive(
      viewModelBuilder: () => FoundationViewModel(),
      onModelReady: (viewModel) async => await viewModel.initState(vsync: this),
      builder: (context, viewModel, child) => ScreenTypeLayout.builder(
        mobile: (BuildContext context) => _FoundationViewMobile(),
      ),
    );
  }
}
