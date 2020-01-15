import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/Posts.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/TribeRoom.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class TribeTile extends StatelessWidget {
  final Tribe tribe;
  final bool active;
  TribeTile({this.tribe, this.active});

  @override
  Widget build(BuildContext context) {
    print('TribeTile: ${tribe.id}');

    final double blur = active ? 20.0 : 10.0;
    final double offset = active ? 0.0 : 0.0;
    final double horizontal = active ? 20.0 : 40.0;

    void _onTribeTap() {
      print('Tapped tribe: ${tribe.name}');
      Navigator.push(context, MaterialPageRoute(
        builder: (_) {
          return TribeRoom();
        },
      ));
    }

    return GestureDetector(
      onTap: () => _onTribeTap(),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeOutQuint,
        margin: EdgeInsets.symmetric(horizontal: horizontal),
        child: Container(
          decoration: BoxDecoration(
              color: Color(tribe.color),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Color(tribe.color),
                  blurRadius: blur,
                  offset: Offset(offset, offset),
                ),
              ]),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${tribe.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${tribe.members.length} member(s)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
