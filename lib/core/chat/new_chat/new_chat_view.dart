library new_chat_view;



import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/chat/new_chat/new_chat_view_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/util_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

part 'new_chat_view_[mobile].dart';

class NewChatView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => NewChatViewModel(),
      onModelReady: (model) => model.initState(),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _NewChatViewMobile(),
        );
      },
    );
  }
}
