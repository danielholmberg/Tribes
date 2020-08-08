library home_view;

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/home/home_view_model.dart';
import 'package:tribes/core/tribe/widgets/tribe_item.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'home_view_mobile.dart';

class HomeView extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    print('HomeView');
    super.build(context);
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomeViewModel(context: context),
      disposeViewModel: false,
      builder: (context, viewModel, child) => ScreenTypeLayout.builder(
        mobile: (BuildContext context) => _HomeViewMobile(viewModel),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
