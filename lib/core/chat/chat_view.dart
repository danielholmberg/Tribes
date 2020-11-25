library chat_view;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/chat/chat_view_model.dart';
import 'package:tribes/core/chat/new_chat_view.dart';
import 'package:tribes/core/chat/widgets/private_messages_tab/private_messages_view.dart';
import 'package:tribes/core/chat/widgets/tribe_messages_tab/tribe_messages_view.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_page_transition.dart';

part 'chat_view_mobile.dart';

class ChatView extends StatefulWidget {
  static const routeName = '/chat';

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('ChatView');
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(context: context),
      disposeViewModel: false,
      builder: (context, viewModel, child) => ScreenTypeLayout.builder(
        mobile: (BuildContext context) => _ChatViewMobile(viewModel),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
