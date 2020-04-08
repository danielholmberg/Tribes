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
  final bool showSecrets;
  JoinedTribes({@required this.user, this.showSecrets});

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

            if(!widget.showSecrets) {
              joinedTribes.removeWhere((tribe) => tribe.secret);
            }
            
            return GridView.builder(
              padding: EdgeInsets.fromLTRB(
                Constants.defaultPadding,
                Constants.defaultPadding,
                Constants.defaultPadding,
                80),
              itemCount: joinedTribes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, i) {
                Tribe currentTribe = joinedTribes[i];
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