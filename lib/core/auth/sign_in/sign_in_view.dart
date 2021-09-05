library sign_in_view;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/auth/auth_view_model.dart';
import 'package:tribes/core/auth/sign_in/sign_in_view_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/extensions.dart';
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_raised_button.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'sign_in_view_[mobile].dart';

class SignInView extends ViewModelWidget<AuthViewModel> {
  @override
  Widget build(BuildContext context, AuthViewModel parentViewModel) {
    return ViewModelBuilder<SignInViewModel>.reactive(
      viewModelBuilder: () => SignInViewModel(),
      onModelReady: (model) => model.initialise(context),
      disposeViewModel: false,
      builder: (context, viewModel, child) => ScreenTypeLayout(
        mobile: _SignInViewMobile(parentViewModel),
      ),
    );
  }
}
