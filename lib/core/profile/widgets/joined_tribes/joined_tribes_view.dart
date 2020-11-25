library joined_tribes_view;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/profile/widgets/joined_tribes/joined_tribes_view_model.dart';
import 'package:tribes/core/tribe/widgets/tribe_item.dart';
import 'package:tribes/core/tribe/widgets/tribe_item_compact.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'joined_tribes_view_[mobile].dart';

class JoinedTribes extends StatefulWidget {
  @override
  _JoinedTribesState createState() => _JoinedTribesState();
}

class _JoinedTribesState extends State<JoinedTribes>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => JoinedTribesViewModel(),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _JoinedTribesViewMobile(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
