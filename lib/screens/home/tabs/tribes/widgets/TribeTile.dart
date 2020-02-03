import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/TribeRoom.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomPageTransition.dart';

class TribeTile extends StatelessWidget {
  final Tribe tribe;
  TribeTile({this.tribe});

  @override
  Widget build(BuildContext context) {
    print('TribeTile: ${tribe.id}');

    return GestureDetector(
      onTap: () {
        print('Tapped tribe: ${tribe.name}');
        Navigator.push(context, CustomPageTransition(
          type: CustomPageTransitionType.tribeRoom,
          child: StreamProvider<Tribe>.value(
            value: DatabaseService().tribe(tribe.id),
            child: TribeRoom(),
          ),
        ));
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeOutQuint,
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
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
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        Icon(
                          Icons.view_list,
                          color: Constants.buttonIconColor,
                          size: Constants.defaultIconSize,
                        ),
                        SizedBox(width: Constants.tinySpacing),
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
                    SizedBox(width: Constants.tinySpacing),
                    Icon(
                      Icons.group,
                      color: Constants.buttonIconColor,
                      size: Constants.defaultIconSize,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
