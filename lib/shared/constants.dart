// ignore: library_names
library Constants;

import 'package:flutter/material.dart';

const String appTitle = 'Tribes';

// Route names
const AuthViewRoute = 'AuthView';
const HomeViewRoute = 'HomeView';
const MapViewRoute = 'MapView';
const ChatViewRoute = 'ChatView';
const ProfileViewRoute = 'ProfileView';

// Core
const primaryColor = Color(0xFFed217c);
const accentColor = Color(0xFFFEF9EB);
const backgroundColor = Color(0xFFfefffd);
const buttonIconColor = Colors.white;
const buttonColor = primaryColor;
const timestampFontSize = 11.0;
const primaryColorHueValue = 333.24;
const whiteWaterMarkColor = Colors.white60;

const defaultPadding = 4.0;
const smallPadding = 2.0;
const mediumPadding = 6.0;
const largePadding = 12.0;

const defaultElevation = 4.0;
const defaultButtonFocusElevation = 8.0;

const pageTransition300 = Duration(milliseconds: 300);
const pageTransition600 = Duration(milliseconds: 600);
const pageTransition800 = Duration(milliseconds: 800);

const defaultDialogTitleFontSize = 20.0;
const defaultDialogTitleFontWeight = FontWeight.w600;
const dialogCornerRadius = 20.0;
const maxCornerRadius = 1000.0;
const defaultProfilePicRadius = 16.0;
const defaultUsernameFontSize = 16.0;
const defaultNameFontSize = 14.0;

const inputLabelColor = primaryColor;
const inputEnabledColor = Color(0x50ed217c);
const inputFocusColor = primaryColor;
const inputCounterColor = inputEnabledColor;

const defaultBoxShadow = BoxShadow(
  color: Colors.black45,
  blurRadius: 4,
  offset: Offset(2, 2),
);

// AppBar
const appBarElevation = 0.0;
const appBarColor = primaryColor;

const defaultSpacing = 16.0;
const smallSpacing = 8.0;
const tinySpacing = 2.0;

const errorFontSize = 14.0;
const errorColor = Colors.red;

// Icons
const bottomBarIconSize = 30.0;
const defaultIconSize = 24.0;
const tinyIconSize = 12.0;
const smallIconSize = 18.0;
const mediumIconSize = 30.0;
const largeIconSize = 46.0;

// Buttons
const buttonElevation = 8.0;
const floatingActionButtonElevation = 4.0;

// Navigation Bar
const tribesColor = primaryColor;
const chatsColor = Color(0xFF59B2B2);
const profileColor = Color(0xFF96B259);
const bottomNavBarBackgroundColor = Color(0xFFf7edde);

// -------- TABs -------- //
// [Tribes]
const tribeNameMaxLength = 20;
const tribeDescMaxLength = 100;
List<Color> defaultTribeColors = [
  primaryColor,
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
];
const tribeDetailIconColor = Color(0xCCFFFFFF); // CC = 80% Opacity

// - Post
const postBackgroundColor = Color(0xFFFAFAFA);
const postInputFocusColor = tribesColor;
const postTileContentMaxLines = 10;
const postTileScaleFactor = 0.5;
const postTileCompactScaleFactor = 1.0;
const postTileCompactImageHeight = 80.0;
const imageGridViewPadding = EdgeInsets.fromLTRB(0.0, 12.0, 16.0, 8.0);
const imageGridViewCrossAxisSpacing = 16.0;
const imageGridViewMainAxisSpacing = 16.0;

// [Map]
// - Chat
const privateChatTabTitle = 'Private';
const tribesChatTabTitle = 'Tribes';
const newMessageFormPadding = 16.0;
const sendButtonColor = chatsColor;
const initialLat = 59.325695;
const initialLng = 18.071869;
const chatMessageAvatarSize = 24.0;

// [Profile]
const profilePagePicRadius = 50.0;
const profileSettingsBackgroundColor = Color(0xFFFAFAFA);
const profileUsernameMaxLength = 20;
const profileInfoMaxLength = 100;

const placeholderPicURL = 'https://picsum.photos/id/237/200/300';


const confirmButtonColor = Colors.green;
const declineButtonColor = Colors.red;
