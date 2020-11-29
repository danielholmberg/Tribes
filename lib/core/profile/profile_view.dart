library profile_view;

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/profile/dialogs/profile_settings_view.dart';
import 'package:tribes/core/profile/profile_view_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';

part 'profile_view_[mobile].dart';

class ProfileView extends StatefulWidget {
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
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      onModelReady: (viewModel) => viewModel.initState(widget.user, this),
      builder: (context, viewModel, child) => ScreenTypeLayout.builder(
        mobile: (BuildContext context) => _ProfileViewMobile(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => widget.user == null;
}
