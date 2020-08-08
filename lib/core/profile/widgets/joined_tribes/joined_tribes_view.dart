import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/core/tribe/join_tribe_view.dart';
import 'package:tribes/core/tribe/new_tribe_view.dart';
import 'package:tribes/core/tribe/widgets/tribe_item.dart';
import 'package:tribes/core/tribe/widgets/tribe_item_compact.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_page_transition.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

// ToDo - Change to Stateless widget and move all state and business-logic to related [viewName]_view_model.dart file.

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

    _showJoinTribePage() {
      Navigator.push(context, CustomPageTransition(
        type: CustomPageTransitionType.joinTribe,
        child: JoinTribeView(),
      ));
    }

    _showNewTribePage() {
      Navigator.push(context, CustomPageTransition(
        type: CustomPageTransitionType.newTribe,
        child: NewTribeView(),
      ));
    }

    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: StreamBuilder<List<Tribe>>(
        initialData: [],
        stream: DatabaseService().joinedTribes(widget.user.id),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            List<Tribe> joinedTribes = snapshot.data;

            if(!widget.showSecrets) {
              joinedTribes.removeWhere((tribe) => tribe.secret);
            }
            
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      Constants.defaultPadding,
                      widget.showSecrets ? 56 : Constants.defaultPadding,
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
                              child: TribeItem(tribe: currentTribe),
                            ),
                          ),
                        ),
                        child: TribeItemCompact(tribe: currentTribe),
                      );
                    },
                  ),
                ),
                widget.showSecrets ? Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Constants.largePadding,
                    Constants.mediumPadding,
                    Constants.largePadding,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton.icon(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1000.0)
                        ),
                        color: DynamicTheme.of(context).data.primaryColor,
                        icon: CustomAwesomeIcon(icon: FontAwesomeIcons.plus, color: Colors.white, size: Constants.smallIconSize),
                        label: Text('Create'),
                        textColor: Colors.white,
                        onPressed: () => _showNewTribePage(),
                      ),
                      RaisedButton.icon(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1000.0)
                        ),
                        color: Constants.primaryColor,
                        icon: CustomAwesomeIcon(icon: FontAwesomeIcons.search, color: Colors.white, size: Constants.smallIconSize),
                        label: Text('Join'),
                        textColor: Colors.white,
                        onPressed: () => _showJoinTribePage(),
                      ),
                    ],
                  ),
                ) : SizedBox.shrink(),
              ],
            );
          } else if(snapshot.hasError) {
            return Container(padding: EdgeInsets.all(16), child: Center(child: Icon(FontAwesomeIcons.exclamationCircle)));
          } else {
            return Loading();
          }
        }
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}