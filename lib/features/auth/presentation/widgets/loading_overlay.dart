import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/features/auth/presentation/widgets/pulse_wave_loader.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    super.key,
    required this.widget,
    required this.isLoading,
  });
  final Widget widget;
  final bool isLoading;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The Main Screen
        widget.widget,

        //The overLay
        if (widget.isLoading)
          Container(
            height: double.infinity,
            width: double.infinity,
            color: AppColors.secondaryColor.withOpacity(0.2),
            child: Center(
              child: PulseWaveLoader(
                size: Dimensions.screenWidth(context) * 0.3,
                color: AppColors.secondaryColor,
              ),
            ),
          ),
      ],
    );
  }
}
