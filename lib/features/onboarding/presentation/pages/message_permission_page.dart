import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/widgets/onboarding_button.dart';

class MessagePermissionPage extends StatefulWidget {
  const MessagePermissionPage({super.key});

  @override
  State<MessagePermissionPage> createState() => _MessagePermissionPageState();
}

class _MessagePermissionPageState extends State<MessagePermissionPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {},
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.horizontal(context),
          ).copyWith(bottom: Dimensions.large),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //-------Icon Container-----
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryColor.withOpacity(0.1),
                      ),
                      padding: EdgeInsets.all(20),
                      //Icon
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        color: AppColors.secondaryColor,
                        size: 80,
                      ),
                    ),

                    SizedBox(height: 20),

                    //------Header Text----------
                    Text(
                      'Enable Auto-Tracking',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.secondaryColor),
                    ),

                    SizedBox(height: 20),

                    //---------Sub Text---------
                    Text(
                      textAlign: TextAlign.center,
                      'To automatically track your expenses, Pulse needs to read your transaction SMS alerts.\n\nWe strictly filter for bank alerts only. Your personal messages remain private and are never read or stored.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              //-----Buttom Button----------
              OnboardingButton(
                onPressed: () {
                  context.read<OnboardingCubit>().grantInitialPermission();
                },
                backgroundColor: AppColors.secondaryColor,
                text: 'Grant Permission',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
