import 'package:flutter/material.dart';
import 'package:tribes/core/tribe/post_room/post_room_view.dart';
import 'package:tribes/core/tribe/widgets/image_carousel.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

class PostItemCompact extends StatefulWidget {
  final Post post;
  final MyUser user;
  final bool viewOnly;
  PostItemCompact({@required this.post, @required this.user, this.viewOnly = false});

  @override
  _PostItemCompactState createState() => _PostItemCompactState();
}

class _PostItemCompactState extends State<PostItemCompact> with TickerProviderStateMixin {

  double cornerRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    final MyUser currentUser = locator<DatabaseService>().currentUserData;
    print('Building PostTileCompact(${widget.post.id})...');

    ThemeData themeData = Theme.of(context);

    bool showUserAvatar = widget.user.id != widget.post.author;

    _postHeader() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AnimatedSize(
            vsync: this,
            alignment: Alignment.centerLeft,
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            child: Container(
              margin: const EdgeInsets.only(top: 4.0, left: 4.0),
              child: StreamBuilder<MyUser>(
                stream: DatabaseService().userData(widget.post.author),
                builder: (context, snapshot) {
                  if(snapshot.hasError) {
                    print('Error retrieving author data: ${snapshot.error.toString()}');
                  } 
                  
                  return UserAvatar(
                    currentUserID: currentUser.id, 
                    user: snapshot.data, 
                    color: themeData.primaryColor,
                    disable: widget.viewOnly,
                    radius: 6,
                    nameFontSize: 6,
                    strokeWidth: 1.0,
                    strokeColor: Colors.white,
                    padding: const EdgeInsets.all(2.0),
                    withDecoration: true,
                    textPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                    textColor: Colors.white,
                  );
                }
              ),
            ),
          ),
        ],
      );
    }

    _postImagesCompactContent() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ImageCarousel(
              images: widget.post.images, 
              color: themeData.primaryColor,
              indicatorPosition: IndicatorPosition.topRight,
              small: true,
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: Visibility(
                visible: showUserAvatar, 
                child: _postHeader(),
              ),
            ),          
          ],
        ),
      );
    }

    _buildCompactCard() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ]
        ),
        child: _postImagesCompactContent(),
      );
    }

    return GestureDetector(
      onTap: () => showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
          return PostRoomView(
            post: widget.post,
          );
        },
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 300),
        transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
              reverseCurve: Curves.easeOut
            ),
            child: child,
          );
        },
      ),
      child: _buildCompactCard(),
    );
  }
}
