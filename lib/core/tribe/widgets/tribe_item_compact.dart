import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';

class TribeItemCompact extends StatelessWidget {
  final Tribe tribe;
  TribeItemCompact({@required this.tribe});

  @override
  Widget build(BuildContext context) {
    print('Building TribeTileCompact(${tribe.id})...');

    _buildTribeName() {
      return AutoSizeText(
        tribe.name,
        textAlign: TextAlign.center,
        maxLines: 2,
        minFontSize: 10.0,
        style: TextStyle(
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.black45
            ),
          ],
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'TribesRounded',
        ),
      );
    }

    _buildSecretTribeWaterMark() {
      return tribe.secret ? CustomAwesomeIcon(
          icon: FontAwesomeIcons.solidEyeSlash,
          color: Constants.whiteWaterMarkColor,
          size: Constants.smallIconSize,
        ) : SizedBox.shrink();
    }
    
    _buildNumberOfPosts() {
      return StreamBuilder<List<Post>>(
        stream: DatabaseService().posts(tribe.id).snapshots()
          .map((list) => list.docs
          .map((doc) => Post.fromSnapshot(doc))
          .toList()
        ),
        builder: (context, snapshot) {
          var postsList = snapshot.hasData ? snapshot.data : []; 

          return Row(
            children: <Widget>[
              CustomAwesomeIcon(
                icon: FontAwesomeIcons.stream,
                color: Constants.tribeDetailIconColor,
                size: Constants.smallIconSize,
              ),
              SizedBox(width: Constants.smallSpacing),
              Text(
                NumberFormat.compact().format(postsList.length),
                style: TextStyle(
                  color: Constants.tribeDetailIconColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TribesRounded',
                ),
              ),
            ],
          );
        }
      );
    }

    _buildNumberOfMembers() {
      return Row(
        children: <Widget>[
          Text(
            NumberFormat.compact().format(tribe.members.length),
            style: TextStyle(
              color: Constants.tribeDetailIconColor,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'TribesRounded',
            ),
          ),
          SizedBox(width: Constants.smallSpacing),
          CustomAwesomeIcon(
            icon: FontAwesomeIcons.userFriends,
            color: Constants.tribeDetailIconColor,
            size: Constants.smallIconSize,
          ),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.all(6.0),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tribe.color,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.black26, width: 2.0),
        boxShadow: [Constants.defaultBoxShadow],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _buildTribeName(),
          Positioned(
            top: 0,
            right: 0,
            child: _buildSecretTribeWaterMark(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _buildNumberOfPosts(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildNumberOfMembers(),
          ),
        ],
      ),
    );
  }
}
