import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';

class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    this.disabledBackgroundColor,
    required this.text,
    required this.style,
  });
  final void Function()? onPressed;
  final Color backgroundColor;
  final Color? disabledBackgroundColor;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Dimensions.smallbuttonHeight,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          // foregroundColor: AppColors.primaryColor,
          // disabledForegroundColor: AppColors.greyAccentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
        ),
        child: Text(text, style: style),
      ),
    );
  }
}
