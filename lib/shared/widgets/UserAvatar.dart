import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';

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
  UserAvatar({
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
  });

  @override
  Widget build(BuildContext context) {
    _layout() {
      return [
        CachedNetworkImage(
          imageUrl: user.picURL,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2.0),
              color: color,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundImage: imageProvider,
              backgroundColor: Colors.transparent,
            ),
          ),
          placeholder: (context, url) => UserAvatarPlaceholder(),
          errorWidget: (context, url, error) => UserAvatarPlaceholder(
            child: Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)),
          ),
        ),
        Visibility(
          visible: !onlyAvatar || withName,
          child: direction == UserAvatarDirections.horizontal 
            ? SizedBox(width: Constants.mediumPadding) 
            : SizedBox(height: Constants.mediumPadding)
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
                  visible: withName || !onlyAvatar,
                  child: Text(withName ? user.name : user.username,
                    style: TextStyle(
                      color: color,
                      fontFamily: 'TribesRounded',
                      fontWeight: FontWeight.bold,
                      fontSize: nameFontSize,
                    ),
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
                          return Text(location,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontFamily: 'TribesRounded',
                              fontSize: 10,
                              fontWeight: FontWeight.normal
                            ),
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
        )
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
      child: direction == UserAvatarDirections.horizontal 
      ? Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _layout()) 
      :  Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _layout()),
    );
  }
}