library chat_room_view;

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/chat/chat_room/chat_room_view_model.dart';
import 'package:tribes/core/chat/widgets/chat_messages.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/user_avatar.dart';

part 'chat_room_view_[mobile].dart';

class ChatRoomView extends StatefulWidget {
  final String roomID;
  final Tribe currentTribe;
  final List<String> members;
  final bool reply;
  ChatRoomView({
    @required this.roomID,
    this.currentTribe,
    this.members,
    this.reply,
  });

  @override
  _ChatRoomViewState createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatRoomViewModel>.reactive(
      viewModelBuilder: () => ChatRoomViewModel(
        roomID: widget.roomID,
        currentTribe: widget.currentTribe,
        members: widget.members,
        reply: widget.reply,
      ),
      onModelReady: (model) => model.initState(context: context),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _ChatRoomViewMobile(),
        );
      },
    );
  }
}
