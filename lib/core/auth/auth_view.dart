import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/auth/auth_view_model.dart';
import 'package:tribes/core/auth/register/register_view.dart';
import 'package:tribes/core/auth/sign_in/sign_in_view.dart';
import 'package:tribes/core/foundation/foundation_view.dart';

class AuthView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel(),
      initialiseSpecialViewModelsOnce: true,
      builder: (context, viewModel, child) {
        return viewModel.isAuthenticated
        ? FoundationView()
        : IndexedStack(
          alignment: Alignment.center,
          sizing: StackFit.expand,
          index: viewModel.currentViewIndex,
          children: [
            SignInView(),
            RegisterView(),
          ],
        );
      },
    );
  }
}
