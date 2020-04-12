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

class UserAvatarPlaceholder extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  UserAvatarPlaceholder({
    this.child,
    this.radius = Constants.defaultProfilePicRadius,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius * 2,
      width: radius * 2,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent, width: 2.0),
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: Constants.defaultProfilePicRadius,
        backgroundColor: Colors.transparent,
        child: child,
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String currentUserID;
  final UserData user;
  final Color color;
  final Future addressFuture;
  final bool onlyAvatar;
  final bool withName; 
  final bool withTextDecoration;
  final double radius;
  final double nameFontSize;
  final UserAvatarDirections direction;
  final EdgeInsets padding;
  final double strokeWidth;
  final Color strokeColor;
  UserAvatar({
    this.currentUserID,
    @required this.user,
    this.color = Constants.primaryColor, 
    this.addressFuture, 
    this.onlyAvatar = false, 
    this.withName = false, 
    this.withTextDecoration = false,
    this.radius = Constants.defaultProfilePicRadius,
    this.nameFontSize = Constants.defaultNameFontSize,
    this.direction = UserAvatarDirections.horizontal,
    this.padding = EdgeInsets.zero,
    this.strokeWidth = 0.0,
    this.strokeColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    bool isMapAvatar = direction == UserAvatarDirections.vertical;

    _layout() {
      return [
        CachedNetworkImage(
          imageUrl: user.picURL,
          imageBuilder: (context, imageProvider) => Container(
            decoration: strokeWidth != 0.0 ? BoxDecoration(
              border: Border.all(color: Colors.white, width: strokeWidth),
              shape: BoxShape.circle,
            ) : null,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2.0),
                color: color,
                shape: BoxShape.circle,
                boxShadow: isMapAvatar ? [
                  BoxShadow(
                    offset: Offset(1, 1),
                    blurRadius: 2.0,
                    color: Colors.black87
                  )
                ] : null
              ),
              child: CircleAvatar(
                radius: radius,
                backgroundImage: imageProvider,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          placeholder: (context, url) => UserAvatarPlaceholder(radius: radius),
          errorWidget: (context, url, error) => UserAvatarPlaceholder(
            child: Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)),
          ),
        ),
        Visibility(
          visible: !onlyAvatar || withName,
          child: isMapAvatar 
            ? SizedBox(height: 0.0)
            : SizedBox(width: Constants.mediumPadding)
        ),
        Visibility(
          visible: !onlyAvatar || withName,
          child: Expanded(
            flex: addressFuture != null ? 1 : 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Visibility(
                  visible: (withName || !onlyAvatar) && !isMapAvatar,
                  child: CustomStrokedText(
                    text: withName ? user.name : user.username,
                    textColor: color,
                    fontWeight: FontWeight.bold,
                    minFontSize: nameFontSize,
                    strokeColor: strokeColor,
                    strokeWidth: strokeWidth,
                  ),
                ),
                Visibility(
                  visible: addressFuture != null,
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: FutureBuilder(
                      future: addressFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var addresses = snapshot.data;
                          var first = addresses.first;
                          var location = '${first.addressLine}';
                          return CustomStrokedText(
                            text: location,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            minFontSize: 10,
                            textColor: strokeWidth != 0.0 ? Colors.white.withOpacity(0.8) : Colors.blueGrey,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.8,
                          );
                        } else if (snapshot.hasError) {
                          print('Error getting address from coordinates: ${snapshot.error}');
                          return SizedBox.shrink();
                        } else {
                          return SizedBox.shrink();
                        }
                        
                      }
                    ),
                  ),
                ),
                
                ],
            ),
          ),
        ),
      ];
    }

    return Container(
      padding: padding,
      decoration: withTextDecoration ? BoxDecoration(
        color: Constants.backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 4.0,
            spreadRadius: 0.0,
            offset: Offset(0, 1),
          ),
        ],
      ) : null,
      child: isMapAvatar
      ? Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _layout(), 
          ),
          Container(
            width: 30,
            child: CustomStrokedText(
              text: withName ? user.name : user.username,
              minFontSize: nameFontSize, 
              maxLines: 3,
              strokeWidth: strokeWidth,
            ),
          ),
        ],
      ) 
      : GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _layout()),
      ),
    );
  }
}