import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/profile/dialogs/ProfileSettings.dart';
import 'package:tribes/screens/home/tabs/profile/widgets/PostTileCompact.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {

  TabController _tabController;
  Coordinates coordinates;
  Future<List<Address>> addressFuture;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Profile()...');
    print('Current user ${currentUser.uid}');

    if((currentUser.lat != 0 && currentUser.lng != 0)) {
      coordinates = Coordinates(currentUser.lat, currentUser.lng);
      addressFuture = Geocoder.local.findAddressesFromCoordinates(coordinates);
    }

    _profileHeader() {
      return Container(
        padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: DynamicTheme.of(context).data.backgroundColor, width: 2.0),
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: 'https://picsum.photos/id/237/200/300',
                          imageBuilder: (context, imageProvider) => CircleAvatar(
                            radius: 50.0,
                            backgroundImage: imageProvider,
                            backgroundColor: Colors.transparent,
                          ),
                          placeholder: (context, url) => Loading(),
                          errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
                        ),
                    ),
                    Positioned(
                      bottom: 0, 
                      right: 0, 
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: DynamicTheme.of(context).data.backgroundColor, width: 2.0),
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(1000.0),
                          onTap: () => print('new pic'),
                          child: Padding(
                            padding:EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.add,
                              size: 14.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('23', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                    Text('Published', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.normal)),
                  ],
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('132', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                    Text('Liked', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.normal)),
                  ],
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('8', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                    Text('Tribes', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.normal)),
                  ],
                ),
                Spacer(),
              ],
            )
          ],
        ),
      );
    }

    _profileInfo() {
      return Card(
        margin: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
        elevation: 8.0,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(currentUser.name,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontFamily: 'TribesRounded',
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: Constants.defaultPadding),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.email, 
                        color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.7),
                        size: Constants.smallIconSize,
                      ),
                      SizedBox(width: Constants.defaultPadding),
                      Text(currentUser.email,
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontFamily: 'TribesRounded',
                          fontSize: 12,
                          fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(height: Constants.defaultPadding),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.person_pin_circle, 
                        color: DynamicTheme.of(context).data.primaryColor.withOpacity(0.7),
                        size: Constants.smallIconSize,
                      ),
                      SizedBox(width: Constants.defaultPadding),
                      FutureBuilder(
                        future: addressFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var addresses = snapshot.data;
                            var first = addresses.first;
                            var location = '${first.addressLine}';
                            print('lat ${currentUser.lat}, lng ${currentUser.lng}');
                            print('location: $location');
                            return Text(location,
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontFamily: 'TribesRounded',
                                fontSize: 10,
                                fontWeight: FontWeight.normal
                              ),
                            );
                          } else if (snapshot.hasError) {
                            print('Error getting address from coordinates: ${snapshot.error}');
                            return SizedBox.shrink();
                          } else {
                            return SizedBox.shrink();
                          }
                          
                        }
                      ),
                    ],
                  )
                ],
              ),
              Divider(),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Text(currentUser.info,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontFamily: 'TribesRounded',
                    fontWeight: FontWeight.normal
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    _createdPosts() {
      return Container(
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: FirestoreAnimatedList(
          padding: EdgeInsets.only(bottom: 80.0),
          query: DatabaseService().postsPublishedByUser(currentUser.uid),
          itemBuilder: (
            BuildContext context,
            DocumentSnapshot snapshot,
            Animation<double> animation,
            int index,
          ) =>
            FadeTransition(
              opacity: animation,
              child: PostTileCompact(post: Post.fromSnapshot(snapshot)),
            ),
            emptyChild: Center(
              child: Text('No posts created yet!'),
            ),
          ),
        ),
      );
    }

    _likedPosts() {
      return Container(
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 80.0),
            itemCount: currentUser.likedPosts.length,
            itemBuilder: (context, index) {
              print('index: $index');
              print('${currentUser.likedPosts[index]}');

              return StreamBuilder<Post>(
                stream: DatabaseService().post(currentUser.uid, currentUser.likedPosts[index]),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    Post likedPost = snapshot.data;
                    return PostTileCompact(post: likedPost);
                  } else if(snapshot.hasError) {
                    return Container(padding: EdgeInsets.all(16), child: Center(child: Icon(Icons.error)));
                  } else {
                    return Loading();
                  }
                }
              );
            }, 
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: DynamicTheme.of(context).data.primaryColor,
      body: Container(
        padding: const EdgeInsets.only(top: 24.0),
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 330,
                  floating: false,
                  pinned: false,
                  elevation: 4.0,
                  backgroundColor: DynamicTheme.of(context).data.primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(currentUser.username,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'TribesRounded',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  )
                                ),
                              ],
                            ),
                            Positioned(right: 0, 
                              child: IconButton(
                                color: DynamicTheme.of(context).data.buttonColor,
                                icon: Icon(Icons.settings, color: Constants.buttonIconColor),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      contentPadding: EdgeInsets.all(0.0),
                                      backgroundColor: Constants.profileSettingsBackgroundColor,
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
                            ),
                          ],
                        ),
                        _profileHeader(),
                        SizedBox(height: Constants.defaultPadding),
                        _profileInfo(),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      labelColor: Constants.buttonIconColor,
                      indicatorColor: Constants.buttonIconColor,
                      unselectedLabelColor: Constants.buttonIconColor.withOpacity(0.7),
                      tabs: [
                        Tab(icon: Icon(Icons.dashboard)),
                        Tab(icon: Icon(Icons.favorite)),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: Container(
              color: DynamicTheme.of(context).data.backgroundColor,
              child: TabBarView(
                children: [
                  _createdPosts(),
                  _likedPosts(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: DynamicTheme.of(context).data.primaryColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
