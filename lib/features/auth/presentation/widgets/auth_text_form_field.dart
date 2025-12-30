import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';

class AuthTextFormField extends StatelessWidget {
  const AuthTextFormField({
    super.key,
    this.isForPassowrd = false,
    required this.hintText,
    required this.controller,
    required this.labelText,
    required this.onChanged,
    required this.validator,
    this.suffixIcon,
  });
  final String hintText;
  final String labelText;
  final bool isForPassowrd;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: AppColors.secondaryColor,
      controller: controller,
      obscureText: isForPassowrd,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(color: AppColors.secondaryColor),
      decoration: InputDecoration(
        //the vertical increases the height of the textfield and so does the textstyle of text we enter
        contentPadding: EdgeInsets.symmetric(
          vertical: (Dimensions.smallbuttonHeight - 24) / 2,
          horizontal: 16,
        ),
        suffixIcon: suffixIcon,
        suffixIconColor: AppColors.secondaryColor,
        hintText: hintText,
        labelText: labelText,
        labelStyle: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
