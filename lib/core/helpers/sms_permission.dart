import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsPermissionHelper {
  static Future<void> requestPermission(BuildContext context) async {
    final smsPermission = await Permission.sms.request();

    if (!context.mounted) return;

    if (smsPermission.isGranted) {
      context.read<OnboardingCubit>().grantSmsPermission();
    } else if (smsPermission.isPermanentlyDenied) {
      _showSettingsDialogue(context);
    } else if (smsPermission.isDenied) {
      _showTryAgainDialogue(context);
    }
  }

  static void _showSettingsDialogue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryColor,

          title: Center(
            child: Text(
              "Permission Required",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.secondaryColor,
              ),
            ),
          ),
          content: Text(
            "We cannot track your expenses without SMS access. Please enable in settings",
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryColor),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyAccentColor,
                  ),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings(); // Function from permission_handler
                },
                child: Text(
                  "Open Settings",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyAccentColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _showTryAgainDialogue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryColor,
          title: Center(
            child: Text(
              "Permission Required",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.secondaryColor,
              ),
            ),
          ),
          content: Text(
            "We cannot track your expenses without SMS access. Please Try again",
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryColor),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: Dimensions.smallbuttonHeight,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.middleGreyColor,
                ),
                onPressed: () async {
                  Navigator.pop(context); // Close dialog first
                  // 🚀 RECURSIVE CALL: Start the check over again
                  await requestPermission(context);
                  // Permission.sms.request();
                  // Navigator.pop(context);
                },
                child: Text(
                  "Request Again",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.greyAccentColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
