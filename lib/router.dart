import 'package:flutter/material.dart';
import 'package:tribes/core/auth/auth_view.dart';
import 'package:tribes/core/chat/chat_room/chat_room_view.dart';
import 'package:tribes/core/chat/chat_view.dart';
import 'package:tribes/core/chat/new_chat/new_chat_view.dart';
import 'package:tribes/core/foundation/foundation_view.dart';
import 'package:tribes/core/map/map_view.dart';
import 'package:tribes/core/profile/profile_view.dart';
import 'package:tribes/core/tribe/join_tribe/join_tribe_view.dart';
import 'package:tribes/core/tribe/new_tribe/new_tribe_view.dart';
import 'package:tribes/core/tribe/tribe_room/tribe_room_view.dart';
import 'package:tribes/models/chat_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_page_transition.dart';

class MyRouter {
  static const String authRoute = '/';
  static const String foundationRoute = 'foundation';
  static const String homeRoute = 'home';
  static const String mapRoute = 'map';
  static const String chatRoute = 'chat';
  static const String profileRoute = 'profile';
  static const String newTribeRoute = 'newTribeRoute';
  static const String joinTribeRoute = 'joinTribeRoute';
  static const String tribeRoomRoute = 'tribeRoute';
  static const String newChatRoute = 'newChatRoute';
  static const String chatRoomRoute = 'chatRoomRoute';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authRoute:
        return MaterialPageRoute(builder: (_) => AuthView());
      case foundationRoute:
        return MaterialPageRoute(builder: (_) => FoundationView());
      case mapRoute:
        return MaterialPageRoute(builder: (_) => MapView());
      case chatRoute:
        return MaterialPageRoute(builder: (_) => ChatView());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => ProfileView());
      case newTribeRoute:
        return CustomPageTransition(
          type: CustomPageTransitionType.newTribe,
          duration: Constants.pageTransition300,
          child: NewTribeView(),
        );
      case joinTribeRoute:
        return CustomPageTransition(
          type: CustomPageTransitionType.joinTribe,
          duration: Constants.pageTransition300,
          child: JoinTribeView(),
        );
      case tribeRoomRoute:
        TribeRoomArguments args = settings.arguments;
        return CustomPageTransition(
          type: CustomPageTransitionType.tribeRoom,
          child: TribeRoomView(
            tribeId: args.tribeId,
            tribeColor: args.tribeColor,
          ),
        );
      case newChatRoute:
        return CustomPageTransition(
          type: CustomPageTransitionType.newMessage,
          duration: Constants.pageTransition300,
          child: NewChatView(),
        );
      case chatRoomRoute:
        ChatRoomArguments args = settings.arguments;
        return CustomPageTransition(
          type: CustomPageTransitionType.chatRoom,
          duration: Constants.pageTransition300,
          child: ChatRoomView(
              roomID: args.roomId, members: args.members, reply: true),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
