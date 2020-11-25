import 'package:flutter/material.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class DiscardChangesDialog extends StatelessWidget {
  final Color color;
  DiscardChangesDialog({this.color = Constants.primaryColor});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
      backgroundColor: themeData.backgroundColor,
      title: Text('Are your sure you want to discard changes?',
        style: TextStyle(
          fontFamily: 'TribesRounded',
          fontWeight: Constants.defaultDialogTitleFontWeight,
          fontSize: Constants.defaultDialogTitleFontSize,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('No', 
            style: TextStyle(
              color: color,
              fontFamily: 'TribesRounded',
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('Yes',
            style: TextStyle(
              color: color,
              fontFamily: 'TribesRounded',
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Dialog: "Are you sure...?"
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}