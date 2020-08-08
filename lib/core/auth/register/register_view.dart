library register_view;

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/auth/auth_view_model.dart';
import 'package:tribes/core/auth/register/register_view_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_raised_button.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'register_view_mobile.dart';

class RegisterView extends ViewModelWidget<AuthViewModel> {
  @override
  Widget build(BuildContext context, AuthViewModel parentViewModel) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => RegisterViewModel(),
      disposeViewModel: false,
      builder: (context, viewModel, child) => ScreenTypeLayout.builder(
        mobile: (BuildContext context) => _RegisterViewMobile(parentViewModel),
      ),
    );
  }
}
