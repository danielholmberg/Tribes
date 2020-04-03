import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/profile/widgets/TribeTileCompact.dart';
import 'package:tribes/screens/home/tabs/tribes/widgets/TribeTile.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class JoinedTribes extends StatefulWidget {
  final UserData user;
  JoinedTribes({@required this.user});

  @override
  _JoinedTribesState createState() => _JoinedTribesState();
}

class _JoinedTribesState extends State<JoinedTribes> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: StreamBuilder<List<Tribe>>(
        initialData: [],
        stream: DatabaseService().joinedTribes(widget.user.uid),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            List<Tribe> joinedTribes = snapshot.data;
            return StaggeredGridView.countBuilder(
              itemCount: joinedTribes.length,
              staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              padding: EdgeInsets.fromLTRB(
                Constants.smallSpacing, 
                Constants.smallSpacing, 
                Constants.smallSpacing, 
                80.0
              ),
              itemBuilder: (context, index) {
                Tribe currentTribe = joinedTribes[index];
                return GestureDetector(
                  onTap: () => showDialog(
                    context: context, 
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                      contentPadding: EdgeInsets.zero,
                      content: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: StreamProvider<UserData>.value(
                          value: DatabaseService().userData(widget.user.uid), 
                          child: TribeTile(tribe: currentTribe),
                        ),
                      ),
                    ),
                  ),
                  child: TribeTileCompact(tribe: currentTribe),
                );
              }, 
            );
          } else if(snapshot.hasError) {
            return Container(padding: EdgeInsets.all(16), child: Center(child: Icon(FontAwesomeIcons.exclamationCircle)));
          } else {
            return CircularProgressIndicator();
          }
        }
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}