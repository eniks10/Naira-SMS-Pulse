import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';

class AppAlerts {
  static void showError({
    required BuildContext context,
    required String error,
  }) {
    _showSnackBar(
      context: context,
      message: error,
      iconColor: AppColors.errorColor,
      icon: Icons.error_outline_rounded,
    );
  }

  static void shoeSuccess({
    required BuildContext context,
    required String message,
  }) {
    _showSnackBar(
      context: context,
      message: message,
      iconColor: AppColors.successColor,
      icon: Icons.error_outline_rounded,
    );
  }

  static void _showSnackBar({
    required BuildContext context,
    required String message,
    required Color iconColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryColor,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.secondaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(Dimensions.horizontal(context)),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1000),
      ),
    );
  }
}
