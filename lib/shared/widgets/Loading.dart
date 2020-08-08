import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class Loading extends StatelessWidget {
  final Color color;
  final double size;
  Loading({this.color = Constants.primaryColor, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitWave(
        type: SpinKitWaveType.center,
        color: color,
        itemCount: 9,
        size: size,
      )
    );
  }
}
