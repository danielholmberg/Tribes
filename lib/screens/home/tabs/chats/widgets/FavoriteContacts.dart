import 'package:flutter/material.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';

class FavoriteContacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Favorite Contacts',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  iconSize: 30.0,
                  color: Colors.blueGrey,
                  onPressed: () {print('Clicked on More button of Favorite Contacts');},
                ),
              ],
            ),
          ),
          Container(
            height: 120.0,
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 10.0),
                itemCount: 20, // TODO
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 35.0,
                          backgroundColor: Colors.red,
                        ),
                        SizedBox(height: 6.0,),
                        Text('Daniel',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
