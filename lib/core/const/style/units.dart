import 'package:flutter/material.dart';

class Units {
  static const double designWidth = 375;
  static const double designHeight = 812;

  static double width(BuildContext context, double value) {
    return MediaQuery.sizeOf(context).width * value / designWidth;
  }

  static double height(BuildContext context, double value) {
    return MediaQuery.sizeOf(context).height * value / designHeight;
  }

  static double textSize(BuildContext context, double value) {
    return MediaQuery.sizeOf(context).width * value / designWidth;
  }

  static double radius(BuildContext context, double value) {
    return MediaQuery.sizeOf(context).width * value / designWidth;
  }
}
