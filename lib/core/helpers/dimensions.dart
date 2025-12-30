import 'package:flutter/widgets.dart';

class Dimensions {
  static screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  //  HORIZONTAL PADDING (The Breakpoint Strategy)
  // Handles the width differences (S21 vs iPhone Pro Max vs Tablet)
  static double horizontal(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 32.0; // Tablets
    if (width > 400) return 24.0; // Iphone promax
    return 16.0; //normal Phone like mine(360)
  }

  //  BOTTOM PADDING (The Safe Area Strategy)
  // Automatically adds the "Swipe Bar" height + your extra spacing
  static double bottom(BuildContext context, {double extra = 16.0}) {
    return MediaQuery.of(context).padding.bottom + extra;
  }

  //  TOP PADDING (The Safe Area Strategy)
  // Automatically adds the "Notch" height + your extra spacing
  static double top(BuildContext context, {double extra = 16.0}) {
    return MediaQuery.of(context).padding.bottom + extra;
  }

  // Consistent vertical spacing
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 40.0;

  //Button
  static double mediumbuttonHeight = 54;
  static double LargebuttonHeight = 64;
  static double smallbuttonHeight = 48;
}
