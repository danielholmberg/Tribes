import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/tribes/screens/EditPost.dart';
import 'package:tribes/screens/base/tribes/widgets/ImageCarousel.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/PostedDateTime.dart';
import 'package:tribes/shared/widgets/UserAvatar.dart';

class PostTileCompact extends StatefulWidget {
  final Post post;
  final UserData user;
  final bool viewOnly;
  PostTileCompact({@required this.post, @required this.user, this.viewOnly = false});

  @override
  _PostTileCompactState createState() => _PostTileCompactState();
}

class _PostTileCompactState extends State<PostTileCompact> with TickerProviderStateMixin {

  double cornerRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Profile()...');
    print('Current user ${currentUser.uid}');

    bool currentUserIsAuthor = currentUser.uid == widget.post.author;
    bool showUserAvatar = widget.user.uid != widget.post.author;

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
              child: StreamBuilder<UserData>(
                stream: DatabaseService().userData(widget.post.author),
                builder: (context, snapshot) {
                  if(snapshot.hasError) {
                    print('Error retrieving author data: ${snapshot.error.toString()}');
                  } 
                  
                  return UserAvatar(
                    currentUserID: currentUser.uid, 
                    user: snapshot.data, 
                    color: DynamicTheme.of(context).data.primaryColor,
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

    _buildDateAndTimeWidget() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: PostedDateTime(
            vsync: this,
            alignment: Alignment.centerRight,
            timestamp: widget.post.created, 
            color: Colors.white,
            fontSize: 6,
            expandedHorizontalPadding: 2.0,
          ),
        ),
      );
    }

    _postDetailsRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ConstrainedBox(
            constraints: (BoxConstraints(maxWidth: MediaQuery.of(context).size.width/3)),
            child: _buildDateAndTimeWidget(),
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
              color: DynamicTheme.of(context).data.primaryColor,
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
            Positioned(
              bottom: 4.0,
              left: 4.0,
              right: 4.0,
              child: _postDetailsRow(),
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
      onTap: widget.viewOnly ? null : () {
        if(currentUserIsAuthor && !widget.viewOnly) {
          showModalBottomSheet(
            context: context,
            isDismissible: false,
            isScrollControlled: true,
            builder: (buildContext) {
              return StreamProvider<UserData>.value(
                value: DatabaseService().currentUser(currentUser.uid), 
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    child: EditPost(post: widget.post),
                  ),
                ),
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 8.0
          );
        }
      },
      child: _buildCompactCard(),
    );
  }
}
