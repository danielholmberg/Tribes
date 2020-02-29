import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class Loading extends StatelessWidget {
  final Color color;
  Loading({this.color = Constants.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DynamicTheme.of(context).data.backgroundColor,
      child: Center(
        child: SpinKitChasingDots(
          color: color,
          size: 50.0,
        ),
      ),
    );
  }
}
