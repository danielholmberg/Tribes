import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/profile/ProfileSettings.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserData>(context);
    print('Building Profile()...');
    print('Current user ${currentUser.uid}');

    return Container(
      child: NestedScrollView(
        reverse: false,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              actions: <Widget>[
                IconButton(
                  color: DynamicTheme.of(context).data.buttonColor,
                  icon: Icon(Icons.settings, color: Constants.buttonIconColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        contentPadding: EdgeInsets.all(0.0),
                        backgroundColor:
                            Constants.profileSettingsBackgroundColor,
                        content: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.8,
                          alignment: Alignment.topLeft,
                          child: ProfileSettings(user: currentUser),
                        ),
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(currentUser.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Image.network(
                    "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
        body: Container(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 20,
                child: Card(
                  elevation: 8.0,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            text: 'Name: ',
                            style: TextStyle(color: Colors.blueGrey, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                text: currentUser.name,
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontFamily: 'TribesRounded',
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Constants.smallSpacing),
                        RichText(
                          text: TextSpan(
                            text: 'Position: ',
                            style: TextStyle(color: Colors.blueGrey, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                text: '[Lat: ${currentUser.lat}, Lng: ${currentUser.lng}]',
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontFamily: 'TribesRounded',
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Constants.smallSpacing),
                        RichText(
                          text: TextSpan(
                            text: 'Info: ',
                            style: TextStyle(color: Colors.blueGrey, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                text: currentUser.info,
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontFamily: 'TribesRounded',
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
