import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomStrokedText.dart';

class PostedDateTime extends StatelessWidget {
  final int timestamp;
  final double fontSize;
  final Color color;
  final double strokeWidth;
  final Color strokeColor;
  PostedDateTime({
    @required this.timestamp, 
    this.fontSize = Constants.timestampFontSize,
    this.color = Constants.primaryColor,
    this.strokeWidth = 0.0,
    this.strokeColor = Colors.white,
  });

  

  @override
  Widget build(BuildContext context) {
    DateTime created = DateTime.fromMillisecondsSinceEpoch(timestamp); 
    String formattedDate = DateFormat('yyyy-MM-dd  kk:mm').format(created);
    
    return CustomStrokedText(
      text: formattedDate,
      textAlign: TextAlign.center, 
      textColor: color.withOpacity(0.5),
      minFontSize: fontSize,
      fontWeight: FontWeight.normal,
      letterSpacing: 1.0,
      strokeWidth: strokeWidth,
      strokeColor: strokeColor.withOpacity(0.5),
    );
  }
}