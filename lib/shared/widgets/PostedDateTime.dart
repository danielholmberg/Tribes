import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class PostedDateTime extends StatefulWidget {
  final int timestamp;
  final double fontSize;
  final Color color;
  final TickerProvider vsync;
  final Duration duration;
  final Alignment alignment;
  final double strokeWidth;
  final Color strokeColor;
  final double expandedHorizontalPadding;
  PostedDateTime({
    @required this.timestamp, 
    this.vsync,
    this.duration = const Duration(milliseconds: 200),
    this.alignment = Alignment.center,
    this.fontSize = Constants.timestampFontSize,
    this.color = Constants.primaryColor,
    this.strokeWidth = 0.0,
    this.strokeColor = Colors.white,
    this.expandedHorizontalPadding = 0.0,
  });

  @override
  _PostedDateTimeState createState() => _PostedDateTimeState();
}

class _PostedDateTimeState extends State<PostedDateTime> {

  String time = '';
  String date = '';
  String year = '';

  bool expanded = false;

  @override
  void initState() {
    Future.delayed(widget.duration).then((onValue) {
      DateTime created = DateTime.fromMillisecondsSinceEpoch(widget.timestamp); 

      if(this.mounted){
        setState(() {
          date = DateFormat.MMMd().format(created);
          time = DateFormat.Hm().format(created);
          year = created.year.toString();
        });
      }
      
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _buildText() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: expanded ? widget.expandedHorizontalPadding : 0.0),
        child: RichText(
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          maxLines: 2,
          softWrap: false,
          text: TextSpan(
            text: '$time ',
            style: TextStyle(
              color: widget.color.withOpacity(0.9),
              fontWeight: FontWeight.normal,
              fontSize: widget.fontSize,
              fontFamily: 'TribesRounded',
            ),
            children: <InlineSpan>[
              TextSpan(
                text: date,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.fontSize,
                  fontFamily: 'TribesRounded',
                ),
              ),
              TextSpan(
                text: expanded ? '\n$year' : '',
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.fontSize,
                  fontFamily: 'TribesRounded',
                ),
              )
            ],
          ),
        ),
      );
    }
    
    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: widget.vsync != null ? AnimatedSize(
        vsync: widget.vsync,
        duration: widget.duration,
        alignment: widget.alignment,
        child: _buildText(),
      ) : _buildText(),
    );
  }
}