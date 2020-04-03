import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    print('Building TribeTile()...');
    print('TribeTile: ${tribe.id}');

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: tribe.color,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: tribe.color,
              blurRadius: 10,
              offset: Offset(0, 0),
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
              AutoSizeText(
                tribe.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 16.0,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TribesRounded',
                ),
              ),
              Padding(
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
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: StreamBuilder<List<Post>>(
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
                      color: Constants.buttonIconColor,
                      size: Constants.smallIconSize,
                    ),
                    SizedBox(width: Constants.smallSpacing),
                    Text(
                      '${postsList.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TribesRounded',
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: <Widget>[
                Text(
                  '${tribe.members.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'TribesRounded',
                  ),
                ),
                SizedBox(width: Constants.smallSpacing),
                CustomAwesomeIcon(
                  icon: FontAwesomeIcons.userFriends,
                  color: Constants.buttonIconColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
