import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';

class TribeTile extends StatelessWidget {
  final Tribe tribe;
  TribeTile({this.tribe});

  @override
  Widget build(BuildContext context) {
    print('Building TribeTile(${tribe.id})...');

    _buildTribeName() {
      return AutoSizeText(
        tribe.name,
        textAlign: TextAlign.center,
        maxLines: 1,
        minFontSize: 16.0,
        style: TextStyle(
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.black45
            ),
          ],
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'TribesRounded',
        ),
      );
    }

    _buildDescription() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: AutoSizeText(
          tribe.desc,
          textAlign: TextAlign.center,
          maxLines: null,
          minFontSize: 12.0,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            fontFamily: 'TribesRounded',
          ),
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
        stream: DatabaseService().posts(tribe.id)
          .map((list) => list.documents
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
                  fontSize: 20.0,
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
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'TribesRounded',
            ),
          ),
          SizedBox(width: Constants.smallSpacing),
          CustomAwesomeIcon(
            icon: FontAwesomeIcons.userFriends,
            color: Constants.tribeDetailIconColor,
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: tribe.color,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.black26, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(4, 4),
            ),
          ]),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 24.0),
            children: <Widget>[
              _buildTribeName(),
              _buildDescription(),
            ],
          ),
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
