import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/features/auth/presentation/widgets/auth_button.dart';

class SmsPermissionPage extends StatelessWidget {
  static const String routeName = 'sms_permission_page';

  const SmsPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.horizontal(context),
            vertical: Dimensions.horizontal(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 1. Hero Image / Icon (Use a Lock or Message Shield icon)
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.mark_email_read_outlined, // Or use SvgPicture
                    size: 60,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 2. The Title
              Text(
                "Enable Auto-Tracking",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // 3. The "Trust" Explanation
              Text(
                "To automatically track your expenses, Pulse needs to read your transaction SMS alerts.\n\nWe strictly filter for bank alerts only. Your personal messages remain private and are never read or stored.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.greyTextColor,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // 4. The Action Button
              AuthButton(
                backGroundColor: AppColors.secondaryColor,
                widget: Text(
                  'Grant Permission',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                borderSide: BorderSide.none,
                onPressed: () {
                  // TODO: Trigger Permission Handler Logic
                  // On Success -> Navigate to Home Dashboard
                },
              ),

              const SizedBox(height: 20),

              // 5. "Not Now" Option (Optional)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to Home (Manual Mode)
                },
                child: Text(
                  "I'll add transactions manually",
                  style: TextStyle(
                    color: AppColors.greyAccentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
