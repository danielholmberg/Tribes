import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/NewPost.dart';
import 'package:tribes/screens/home/tabs/tribes/posts/Posts.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';

class TribeRoom extends StatefulWidget {

  final Tribe tribe;
  TribeRoom({this.tribe});

  @override
  _TribeRoomState createState() => _TribeRoomState();
}

class _TribeRoomState extends State<TribeRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DynamicTheme.of(context).data.backgroundColor,
      extendBody: true,
      body: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: NestedScrollView(
          reverse: false,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                elevation: 8.0,
                backgroundColor: DynamicTheme.of(context).data.primaryColor,
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                titleSpacing: 8.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                )),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.sort),
                    iconSize: 30.0,
                    color: Colors.white,
                    onPressed: () {
                      print('Clicked on Sort button');
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: EdgeInsets.symmetric(vertical: 8.0),
                  title: Text(
                    widget.tribe.name,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'TribesRounded'
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            child: Stack(
              children: <Widget>[
                Posts(tribeID: widget.tribe.id),
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: ButtonTheme(
                    height: 50.0,
                    minWidth: MediaQuery.of(context).size.width,
                    child: RaisedButton.icon(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      color: DynamicTheme.of(context).data.primaryColor,
                      icon: Icon(Icons.library_add,
                        color: DynamicTheme.of(context).data.accentColor
                      ),
                      label: Text('Write a post'),
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(context, 
                          MaterialPageRoute(
                            builder: (_) => NewPost(tribeID: widget.tribe.id)
                          )
                        );
                      },
                    ),
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
