import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/tribes/screens/EditPost.dart';
import 'package:tribes/screens/base/tribes/widgets/ImageCarousel.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomStrokedText.dart';
import 'package:tribes/shared/widgets/LikeButton.dart';
import 'package:tribes/shared/widgets/UserAvatar.dart';

class PostTileCompact extends StatelessWidget {
  final Post post;
  final bool viewOnly;
  PostTileCompact({@required this.post, this.viewOnly = false});

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Profile()...');
    print('Current user ${currentUser.uid}');

    bool isAuthor = currentUser.uid == post.author;
    bool hasImages = post.images.isNotEmpty;

    _postTileHeader() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: StreamBuilder<UserData>(
              stream: DatabaseService().userData(post.author),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return UserAvatar(
                    currentUserID: currentUser.uid, 
                    user: snapshot.data,
                    radius: 10, 
                    nameFontSize: 9,
                    color: DynamicTheme.of(context).data.primaryColor, 
                    strokeWidth: hasImages ? 1.0 : 0.0,
                    strokeColor: Colors.white,
                  );
                } else if(snapshot.hasError) {
                  print('Error retrieving author data: ${snapshot.error.toString()}');
                  return UserAvatarPlaceholder(child: Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)));
                } else {
                  return UserAvatarPlaceholder();
                }
              }
            ),
          ),
        ],
      );
    }

    _postTileFooter() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
            // Left Icons placeholder
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomStrokedText(
                  text: '${post.likes}',
                  textColor: DynamicTheme.of(context).data.primaryColor,
                  strokeColor: Colors.white,
                  minFontSize: 8,
                  fontWeight: FontWeight.bold,
                  strokeWidth: 4,
                ),
              ),
            ],
          ),           
        ],
      );
    }

    _postTileMain() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[

            // Images
            Visibility(
              visible: hasImages,
              child: ImageCarousel(images: post.images, small: true),
            ),

            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  // Header
                  Container(
                    padding: EdgeInsets.fromLTRB(4.0, 4.0, 0.0, 0.0),
                    child: _postTileHeader()
                  ),
                  
                  // Title
                  Container(
                    padding: EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 0.0),
                    child: CustomStrokedText(
                      text: post.title,
                      textColor: hasImages ? Colors.white : Colors.black,
                      textAlign: TextAlign.start,
                      strokeColor: Colors.black87,
                      strokeWidth: hasImages ? 4.0 : 0.0,
                      letterSpacing: 1.0,
                      maxLines: null,
                      fontWeight: DynamicTheme.of(context).data.textTheme.title.fontWeight,
                      minFontSize: 12,
                    ),
                  ),

                  // Content
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: CustomStrokedText(
                      text: post.content,
                      textColor: hasImages ? Colors.white : Colors.black,
                      textAlign: TextAlign.start,
                      strokeColor: Colors.black,
                      strokeWidth: hasImages ? 2.0 : 0.0,
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                      fontWeight: DynamicTheme.of(context).data.textTheme.body1.fontWeight,
                      minFontSize: 8,
                    ),
                  ),
                ],
              ),

            // Footer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _postTileFooter(),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: viewOnly ? null : () {
        if(isAuthor) {
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
                    child: EditPost(post: post),
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
      child: Container(
        decoration: BoxDecoration(
          color: DynamicTheme.of(context).data.backgroundColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [Constants.defaultBoxShadow],
        ),
        child: _postTileMain()
        ),
    );
  }
}
