import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class PostedDateTime extends StatelessWidget {
  final int timestamp;
  final double fontSize;
  final Color color;
  PostedDateTime({
    @required this.timestamp, 
    this.fontSize = Constants.timestampFontSize,
    this.color = Constants.primaryColor
  });

  

  @override
  Widget build(BuildContext context) {
    DateTime created = DateTime.fromMillisecondsSinceEpoch(timestamp); 
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(created);
    
    return Text(formattedDate,
      textAlign: TextAlign.center, 
      style: TextStyle(
        color: color.withOpacity(0.8),
        fontFamily: 'TribesRounded',
        fontSize: fontSize,
      ),
    );
  }
}