import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/home/tabs/chats/widgets/PrivateMessages.dart';
import 'package:tribes/screens/home/tabs/chats/widgets/TribeMessages.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> with AutomaticKeepAliveClientMixin {

  int _currentCategory = 0;
  final List<String> categories = ['Private', 'Tribes'];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building Chats()...');
    print('Current user ${currentUser.toString()}');

    _categorySelector() {
      return Container(
        height: 80.0,
        color: DynamicTheme.of(context).data.primaryColor,
        child: Center(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => setState(() => _currentCategory = index),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: index == _currentCategory ? Colors.white : Colors.white60,
                      fontFamily: 'TribesRounded',
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    _privateMessages() {
      return Column(
        children: <Widget>[
          PrivateMessages(),
        ],
      );
    }

    _tribeMessages() {
      return Column(
        children: <Widget>[
          TribeMessages(),
        ],
      );
    }

    return Container(
      color: DynamicTheme.of(context).data.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: DynamicTheme.of(context).data.primaryColor,
          body: Column(
            children: <Widget>[
              _categorySelector(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: DynamicTheme.of(context).data.backgroundColor,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      ),
                    ]
                  ),
                  child: _currentCategory == 0 ? _privateMessages() : _tribeMessages(), 
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
