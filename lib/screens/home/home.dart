import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/chats/Chats.dart';
import 'package:tribes/screens/home/tabs/profile/Profile.dart';
import 'package:tribes/screens/home/tabs/tribes/Tribes.dart';
import 'package:tribes/screens/home/tabs/map/Map.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomBottomNavBar.dart';
import 'package:tribes/shared/widgets/CustomNavBarItem.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{

  int _currentIndex = 0;
  final List<Widget> _tabList = [Tribes(), Map(), Chats(), Profile()];
  TabController _tabController;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _tabController = TabController(length: _tabList.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([]);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabTap(int currentIndex) {
    print('$currentIndex');
    _tabController.animateTo(currentIndex);
    setState(() {
      _currentIndex = currentIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);

    return StreamProvider<UserData>.value(
      value: DatabaseService().currentUser(user.uid),
      child: Scaffold(
        backgroundColor: DynamicTheme.of(context).data.backgroundColor,
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(), // Disable horizontal swipe
          controller: _tabController,
          children: _tabList,
        ),
        extendBody: true, // In order to show screen behind navigation bar
        bottomNavigationBar: Container(
          child: CustomBottomNavBar(
            currentIndex: _currentIndex,
            backgroundColor: DynamicTheme.of(context).data.primaryColor,
            selectedItemColor: DynamicTheme.of(context).data.primaryColor,
            fontSize: 12.0,
            items: [
              CustomNavBarItem(icon: Icons.home, title: 'Tribes'),
              CustomNavBarItem(icon: Icons.map, title: 'Map'),
              CustomNavBarItem(icon: Icons.chat, title: 'Chat'),
              CustomNavBarItem(icon: Icons.person, title: 'Profile'),
            ],
            onTap: (index) {
              _onTabTap(index);
              return index;
            },
          ),
        ),
      ),
    );
  }
}
