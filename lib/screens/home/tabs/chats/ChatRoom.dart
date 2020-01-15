import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {

  final String roomID;
  ChatRoom({this.roomID});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  String message = '';

  _buildMessage(/*Message message,*/ bool isMe) {
    final Container msg = Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: isMe 
        ? EdgeInsets.only(top: 8.0, bottom: 8.0, left: 80.0) 
        : EdgeInsets.only(top: 8.0, bottom: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: isMe ? DynamicTheme.of(context).data.accentColor : Color(0xFFFFEFEE),
        borderRadius: isMe 
          ? BorderRadius.only(
            topLeft: Radius.circular(15.0),
            bottomLeft: Radius.circular(15.0),
          )
          : BorderRadius.only(
            topRight: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('23:12',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.0),
          Text('Message conent, bla bla bla',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if(isMe) {
      return msg;
    }

    return Row(
      children: <Widget>[
        msg, 
        IconButton(
          icon: Icon(Icons.favorite_border), //TODO: message.isLiked ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
          iconSize: 30.0,
          color: Colors.blueGrey, //TODO: message.isLiked ? DynamicTheme.of(context).data.primaryColor : Colors.blueGrey,
          onPressed: () {print('Clicked on More button');},
        ),
      ],
    );
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: DynamicTheme.of(context).data.primaryColor,
            onPressed: () {print('Picking image to attach...');},
          ),
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
              onChanged: (val) => setState(() => message = val),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: DynamicTheme.of(context).data.primaryColor,
            onPressed: () {print('Sending message...');},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DynamicTheme.of(context).data.primaryColor,
      appBar: AppBar(
        backgroundColor: DynamicTheme.of(context).data.primaryColor,
        elevation: 0.0,
        title: Text('Daniel',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {print('Clicked on More button');},
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
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
                  child: ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.only(top: 15.0),
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      //TODO: final Message message = messages[index];
                      //TODO: bool isMe = message.sender.id == currentUser.id;
                      bool isMe = true;
                      return _buildMessage(isMe);
                    }
                  ),
                ),
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }
}
