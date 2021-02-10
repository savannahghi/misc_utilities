import 'package:flutter/material.dart';

class CheckDeviceOrientation {
  static bool isLandscape({@required BuildContext context}) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return true;
    } else {
      return false;
    }
  }
}
