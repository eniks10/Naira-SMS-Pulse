import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.backGroundColor,
    required this.widget,
    required this.borderSide,
    required this.onPressed,
  });
  final Color backGroundColor;
  final Widget widget;
  final BorderSide borderSide;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimensions.smallbuttonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: borderSide,
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
          backgroundColor: backGroundColor,
        ),
        child: widget,
      ),
    );
  }
}
