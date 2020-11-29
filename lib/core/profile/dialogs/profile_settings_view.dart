library profile_settings_view;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/profile/dialogs/profile_settings_view_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_button.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/discard_changes_dialog.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'profile_settings_view_[mobile].dart';

class ProfileSettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return ViewModelBuilder<ProfileSettingsViewModel>.reactive(
      viewModelBuilder: () => ProfileSettingsViewModel(),
      onModelReady: (model) => model.initState(context, themeData),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _ProfileSettingsViewMobile(),
        );
      },
    );
  }
}
