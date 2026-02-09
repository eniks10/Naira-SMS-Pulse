import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_state.dart';

class DateSelectorWidget extends StatelessWidget {
  const DateSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final start = state.selectedDateRange.start;
        final end = state.selectedDateRange.end;

        // Format: "Dec 12 - Jan 01"
        final fmt = DateFormat('MMM d');
        final dateString = "${fmt.format(start)} - ${fmt.format(end)}";

        return GestureDetector(
          onTap: () => _pickDateRange(context, state.selectedDateRange),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Hug content
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.secondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  dateString,
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    DateTimeRange currentRange,
  ) async {
    final newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: currentRange,
      builder: (context, child) {
        // Custom Theme for the Calendar
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondaryColor,
              onPrimary: Colors.white,
              surface: AppColors.primaryColor,
              onSurface: AppColors.secondaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      context.read<HomeBloc>().add(DateRangeChangedEvent(newRange));
    }
  }
}
