import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';

//Text Theme
final baseFontTheme = GoogleFonts.ibmPlexMonoTextTheme();
final TextTheme myFontTheme = baseFontTheme.copyWith(
  headlineLarge: baseFontTheme.headlineLarge?.copyWith(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    letterSpacing: 8.0,
  ),
  headlineMedium: baseFontTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.w600,
    fontSize: 24,
    letterSpacing: 2.0,
  ),
  headlineSmall: baseFontTheme.headlineSmall?.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  ),
  bodyLarge: baseFontTheme.bodyLarge?.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  ),
  bodyMedium: baseFontTheme.bodyMedium?.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.0,
  ),

  bodySmall: baseFontTheme.bodySmall?.copyWith(
    fontSize: 8,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
  ),
);

// TextField Theme

final baseOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AppColors.secondaryColor, width: 1.5),
  borderRadius: BorderRadius.circular(10),
);

final InputDecorationTheme myInputDecorationTheme = InputDecorationTheme(
  hintStyle: baseFontTheme.bodyMedium?.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryColor,
  ),
  errorStyle: baseFontTheme.bodyMedium?.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.errorColor,
  ),
  enabledBorder: baseOutlineInputBorder,
  focusedBorder: baseOutlineInputBorder.copyWith(
    borderSide: BorderSide(color: AppColors.greyAccentColor),
  ),
  // errorBorder: baseOutlineInputBorder.copyWith(
  //   borderSide: BorderSide(color: AppColors.errorColor),
  // ),
  errorBorder: baseOutlineInputBorder,

  focusedErrorBorder: baseOutlineInputBorder.copyWith(
    borderSide: BorderSide(color: AppColors.greyAccentColor),
  ),
  disabledBorder: baseOutlineInputBorder,
);

class AppTheme {
  static final light = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.primaryColor,
    textTheme: myFontTheme,
    inputDecorationTheme: myInputDecorationTheme,
  );

  static final dark = ThemeData(
    primaryColor: AppColors.secondaryColor,
    scaffoldBackgroundColor: AppColors.secondaryColor,
    textTheme: myFontTheme,
  );
}
