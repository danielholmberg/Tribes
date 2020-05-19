import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/profile/Profile.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomStrokedText.dart';

enum UserAvatarDirections {
  vertical,
  horizontal
}

class UserAvatar extends StatelessWidget {
  final String currentUserID;
  final UserData user;
  final Color color;
  final bool onlyAvatar;
  final bool withName; 
  final double radius;
  final double nameFontSize;
  final UserAvatarDirections direction;
  final EdgeInsets padding;
  final double strokeWidth;
  final Color strokeColor;
  final BoxDecoration decoration;
  final BoxShadow shadow;
  final bool withDecoration;
  final EdgeInsets textPadding;
  final Color textColor;
  final bool disable;
  UserAvatar({
    this.currentUserID,
    @required this.user,
    this.color = Constants.primaryColor, 
    this.onlyAvatar = false, 
    this.withName = false, 
    this.radius = Constants.defaultProfilePicRadius,
    this.nameFontSize = Constants.defaultNameFontSize,
    this.direction = UserAvatarDirections.horizontal,
    this.padding,
    this.strokeWidth = 2.0,
    this.strokeColor = Colors.white,
    this.decoration,
    this.shadow,
    this.withDecoration = false,
    this.textPadding = EdgeInsets.zero,
    this.textColor = Colors.white,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    
    bool isMapAvatar = direction == UserAvatarDirections.vertical;

    _circleAvatar({ImageProvider imageProvider, Widget child}) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: color, width: strokeWidth),
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
          backgroundColor: Colors.transparent,
          child: child,
        ),
      );
    }

    _placeholderLayout() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _circleAvatar(),
        ],
      );
    }

    _userAvatarLayout() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          user != null ? CachedNetworkImage(
            imageUrl: user.picURL,
            imageBuilder: (context, imageProvider) => _circleAvatar(imageProvider: imageProvider),
            placeholder: (context, url) => _circleAvatar(),
            errorWidget: (context, url, error) => _circleAvatar(
              child: Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)),
            ),
          ) : _circleAvatar(),
          Visibility(
            visible: !onlyAvatar || withName,
            child: Padding(
              padding: textPadding ?? EdgeInsets.symmetric(horizontal: (isMapAvatar ? 0.0 : 4.0)),
              child: Visibility(
                visible: (withName || !onlyAvatar) && !isMapAvatar,
                child: AutoSizeText(
                  user != null ? withName ? user.name : user.username : '',
                  maxFontSize: nameFontSize,
                  minFontSize: 6,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TribesRounded'
                  )
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: padding,
      decoration: withDecoration ? BoxDecoration(
        color: color.withOpacity(0.6),
        borderRadius: BorderRadius.circular(1000.0),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 0),
            blurRadius: 2.0,
            color: color.withOpacity(0.5)
          )
        ]
      ) : (shadow != null ? BoxDecoration(borderRadius: BorderRadius.circular(1000), boxShadow: [shadow]) : null),
      child: isMapAvatar
      ? Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _userAvatarLayout(),
          CustomStrokedText(
            text: withName ? '${user.name[0].toUpperCase()}${user.name[1]}' : '${user.username[0].toUpperCase()}${user.username[1]}',
            minFontSize: nameFontSize, 
            maxLines: 1,
            letterSpacing: 2.0,
            strokeWidth: strokeWidth,
            strokeColor: color.withOpacity(0.8),
          ),
        ],
      ) 
      : ClipRRect(
        borderRadius: BorderRadius.circular(1000),
        child: AnimatedCrossFade(
          duration: Duration(milliseconds: 300),
          alignment: Alignment.center,
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeIn,
          crossFadeState: user == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _placeholderLayout(),
          secondChild: GestureDetector(
            onTap: disable ? null : () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.black.withOpacity(0.7),
                    width: 2.0
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                contentPadding: EdgeInsets.zero,
                content: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: StreamProvider<UserData>.value(
                      value: DatabaseService().currentUser(currentUserID),
                      child: Profile(user: user),
                    ),
                  ),
                ),
              ),
            ),
            child: _userAvatarLayout(),
          ),
        ),
      ),
    );
  }
}