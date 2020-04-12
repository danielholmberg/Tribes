import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomStrokedText extends StatelessWidget {
  final String text;
  final double maxFontSize;
  final double minFontSize;
  final Color textColor;
  final Color strokeColor;
  final double strokeWidth;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final FontWeight fontWeight;
  final int maxLines;
  final bool softWrap;
  final double letterSpacing;
  CustomStrokedText({
    @required this.text,
    @required this.minFontSize,
    this.maxFontSize,
    this.textColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 0.0,
    this.overflow = TextOverflow.fade,
    this.textAlign = TextAlign.center,
    this.fontWeight = FontWeight.bold,
    this.maxLines = 1,
    this.softWrap = true,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Visibility(
          visible: strokeWidth != 0.0,
          child: AutoSizeText(text,
            softWrap: softWrap,
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
            minFontSize: minFontSize,
            style: TextStyle(
              foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
              fontFamily: 'TribesRounded',
              fontWeight: fontWeight,
              fontSize: maxFontSize ?? minFontSize,
              letterSpacing: letterSpacing,
            ),
          ),
        ),
        AutoSizeText(text,
          softWrap: softWrap,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
          minFontSize: minFontSize,
          style: TextStyle(
            color: textColor,
            fontFamily: 'TribesRounded',
            fontWeight: fontWeight,
            fontSize: maxFontSize ?? minFontSize,
            letterSpacing: letterSpacing,
          ),
        ),
      ],
    );
  }
}