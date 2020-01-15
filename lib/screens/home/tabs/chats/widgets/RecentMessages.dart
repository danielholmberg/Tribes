import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:tribes/screens/home/tabs/chats/ChatRoom.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';

class RecentMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 6.0, bottom: 75.0),
              itemCount: 10,  //TODO: Map to number of ChatRooms
              itemBuilder: (context, index) {
                //final Chat chat = chats[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context, 
                    MaterialPageRoute(
                      builder: (_) { 
                        return ChatRoom(roomID: '1234'); //TODO: Map with ChatRoomID
                      },
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 20.0),
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFEFEE), // TODO: chat.unread ?  Color(0xFFFFEFEE) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 35.0,
                              backgroundColor: Colors.red,
                            ),
                            SizedBox(width: 10.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Daniel',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6.0),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.45,
                                  child: Text('Message content, bla bla bla.',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text('23:12',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            // TODO: chat.unread ? Container(...) : Text(''),
                            Container(
                              width: 40.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: DynamicTheme.of(context).data.primaryColor,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              alignment: Alignment.center,
                              child: Text('New',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
