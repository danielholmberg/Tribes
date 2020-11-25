library profile_view;

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/profile/dialogs/profile_settings_dialog.dart';
import 'package:tribes/core/profile/profile_view_model.dart';
import 'package:tribes/core/profile/widgets/created_posts/created_posts_view.dart';
import 'package:tribes/core/profile/widgets/joined_tribes/joined_tribes_view.dart';
import 'package:tribes/core/profile/widgets/liked_posts/liked_posts_view.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'profile_view_mobile.dart';

class ProfileView extends StatefulWidget {
  static const routeName = '/profile';

  final MyUser user;
  ProfileView({this.user});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('ProfileView');
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(user: widget.user),
      onModelReady: (viewModel) => viewModel.initState(this),
      disposeViewModel: false,
      builder: (context, viewModel, child) => ScreenTypeLayout.builder(
        mobile: (BuildContext context) => _ProfileViewMobile(viewModel),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.user == null;
}
