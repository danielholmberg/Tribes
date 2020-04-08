import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';

class TribeTileCompact extends StatelessWidget {
  final Tribe tribe;
  TribeTileCompact({@required this.tribe});

  @override
  Widget build(BuildContext context) {
    print('Building TribeTile()...');
    print('TribeTile: ${tribe.id}');
    return Container(
          margin: EdgeInsets.all(6.0),
          padding: EdgeInsets.all(12),
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
              AutoSizeText(
                tribe.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                minFontSize: 10.0,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TribesRounded',
                ),
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
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'TribesRounded',
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
              tribe.secret ? Positioned(
                top: 0,
                right: 0,
                child: CustomAwesomeIcon(
                  icon: FontAwesomeIcons.solidEyeSlash,
                  color: Constants.whiteWaterMarkColor,
                  size: Constants.smallIconSize,
                ),
              ) : SizedBox.shrink(),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  children: <Widget>[
                    Text(
                      '${tribe.members.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TribesRounded',
                      ),
                    ),
                    SizedBox(width: Constants.smallSpacing),
                    CustomAwesomeIcon(
                      icon: FontAwesomeIcons.userFriends,
                      color: Constants.buttonIconColor,
                      size: Constants.smallIconSize,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}
