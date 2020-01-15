import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: DynamicTheme.of(context).data.primaryColor,
      child: Center(
        child: SpinKitChasingDots(
          color: DynamicTheme.of(context).data.accentColor,
          size: 50.0,
        ),
      ),
    );
  }
}