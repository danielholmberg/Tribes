library private_messages_view;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/animated_firestore_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/chat/chat_room_view.dart';
import 'package:tribes/core/chat/widgets/private_messages_tab/private_messages_view_model.dart';
import 'package:tribes/models/chat_message_model.dart';
import 'package:tribes/models/chat_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_page_transition.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

part 'private_messages_view_mobile.dart';

class PrivateMessagesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('PrivateMessagesView');

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => PrivateMessagesViewModel(),
      disposeViewModel: false,
      builder: (context, model, child) => ScreenTypeLayout.builder(
        mobile: (BuildContext context) => _PrivateMessagesViewMobile(),
      ),
    );
  }
}
