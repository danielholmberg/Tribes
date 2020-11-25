import 'package:flutter/material.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';

class CustomRaisedButton extends StatelessWidget {
  final FocusNode focusNode;
  final Function onPressed;
  final String text;
  final Color color;
  final bool inverse;
  final CustomAwesomeIcon icon;
  CustomRaisedButton({
    @required this.onPressed,
    @required this.text,
    this.color,
    this.focusNode,
    this.inverse = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return RaisedButton(
      focusNode: focusNode,
      color: inverse ? themeData.backgroundColor : color ?? themeData.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          icon != null ? icon : SizedBox.shrink(),
          Visibility(visible: icon != null, child: SizedBox(width: Constants.smallSpacing)),
          Text(
            text, 
            style: themeData.textTheme.button.copyWith(
              color: inverse ? themeData.primaryColor : Constants.buttonIconColor,
              fontWeight: FontWeight.bold,
            )
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}