import 'package:flutter/material.dart';
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class CustomButton extends StatelessWidget {
  final double height;
  final double width;
  final IconData icon;
  final Color iconColor;
  final Color color;
  final Widget label;
  final Color labelColor;
  final Function onPressed;
  final EdgeInsets margin;
  CustomButton({
    this.height, 
    this.width, 
    @required this.icon, 
    @required this.onPressed, 
    @required this.label, 
    this.margin,
    this.iconColor = Constants.buttonIconColor,
    this.color = Constants.primaryColor,
    this.labelColor = Colors.white,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ButtonTheme(
        height: height,
        minWidth: width,
        child: RaisedButton.icon(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1000.0)
          ),
          color: color,
          icon: CustomAwesomeIcon(icon: icon, color: iconColor, size: Constants.smallIconSize),
          label: label,
          textColor: labelColor,
          onPressed: onPressed,
        ),
      ),
    );
  }
}