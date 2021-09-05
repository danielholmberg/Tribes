library tribe_messages_view;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/chat/chat_room/chat_room_view.dart';
import 'package:tribes/core/chat/widgets/chat_messages.dart';
import 'package:tribes/core/chat/widgets/tribe_messages_tab/tribe_messages_view_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_page_transition.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

part 'tribe_messages_view_[mobile].dart';

class TribeMessagesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TribeMessagesViewModel>.reactive(
      viewModelBuilder: () => TribeMessagesViewModel(),
      disposeViewModel: false,
      builder: (context, viewModel, child) {
        return ScreenTypeLayout.builder(
          mobile: (BuildContext context) => _TribeMessagesViewMobile(viewModel),
        );
      },
    );
  }
}
