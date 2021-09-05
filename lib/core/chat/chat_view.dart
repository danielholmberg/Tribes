library chat_view;

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/chat/chat_view_model.dart';
import 'package:tribes/core/chat/widgets/private_messages_tab/private_messages_view.dart';
import 'package:tribes/core/chat/widgets/tribe_messages_tab/tribe_messages_view.dart';

part 'chat_view_[mobile].dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      onModelReady: (model) => model.initState(context: context),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _ChatViewMobile(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
