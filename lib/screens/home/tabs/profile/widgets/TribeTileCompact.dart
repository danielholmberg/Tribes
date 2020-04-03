import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';

class TribeTileCompact extends StatelessWidget {
  final Tribe tribe;
  TribeTileCompact({this.tribe});

  @override
  Widget build(BuildContext context) {
    print('Building TribeTile()...');
    print('TribeTile: ${tribe.id}');
    return Container(
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
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            tribe.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'TribesRounded',
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              StreamBuilder<List<Post>>(
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

              Row(
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
            ],
          ),
        ],
      ),
    );
  }
}
