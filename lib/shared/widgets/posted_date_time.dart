import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class PostedDateTime extends StatefulWidget {
  final DateTime timestamp;
  final double fontSize;
  final Color color;
  final TickerProvider vsync;
  final Duration duration;
  final Alignment alignment;
  final double strokeWidth;
  final Color strokeColor;
  final bool fullscreen;
  PostedDateTime({
    @required this.timestamp, 
    this.vsync,
    this.duration = const Duration(milliseconds: 200),
    this.alignment = Alignment.center,
    this.fontSize = Constants.timestampFontSize,
    this.color = Constants.primaryColor,
    this.strokeWidth = 0.0,
    this.strokeColor = Colors.white,
    this.fullscreen = false,
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

      if(this.mounted){
        setState(() {
          date = DateFormat.MMMd().format(widget.timestamp);
          time = DateFormat.Hm().format(widget.timestamp);
          year = widget.timestamp.year.toString();
        });
      }
      
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _buildText() {
      return RichText(
        textAlign: TextAlign.center,
        overflow: TextOverflow.fade,
        maxLines: 1,
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
              text: expanded || widget.fullscreen ? ', $year' : '',
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.bold,
                fontSize: widget.fontSize,
                fontFamily: 'TribesRounded',
              ),
            )
          ],
        ),
      );
    }
    
    return IgnorePointer(
      ignoring: widget.fullscreen,
      child: GestureDetector(
        onTap: () => setState(() => expanded = !expanded),
        child: widget.vsync != null ? AnimatedSize(
          vsync: widget.vsync,
          duration: widget.duration,
          alignment: widget.alignment,
          child: _buildText(),
        ) : _buildText(),
      ),
    );
  }
}