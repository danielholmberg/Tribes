import 'package:dynamic_theme/dynamic_theme.dart';
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
    return RaisedButton(
      focusNode: focusNode,
      color: inverse ? DynamicTheme.of(context).data.backgroundColor : color ?? DynamicTheme.of(context).data.primaryColor,
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
            style: DynamicTheme.of(context).data.textTheme.button.copyWith(
              color: inverse ? DynamicTheme.of(context).data.primaryColor : Constants.buttonIconColor,
              fontWeight: FontWeight.bold,
            )
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}