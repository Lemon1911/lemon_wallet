import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 800.0;
    return 1000.0;
  }
}
