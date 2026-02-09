import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTimeRange? initialDateRange;

  const CustomDateRangePicker({super.key, this.initialDateRange});

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  // Store the selected range as a list of DateTimes (package format)
  List<DateTime?> _dialogCalendarPickerValue = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing range if available
    if (widget.initialDateRange != null) {
      _dialogCalendarPickerValue = [
        widget.initialDateRange!.start,
        widget.initialDateRange!.end,
      ];
    } else {
      _dialogCalendarPickerValue = [DateTime.now()];
    }
  }

  // Helper to handle "Last X Days" button clicks
  void _selectQuickDateRange(int days) {
    final now = DateTime.now();
    setState(() {
      _dialogCalendarPickerValue = [now.subtract(Duration(days: days)), now];
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDateSet =
        (_dialogCalendarPickerValue.length == 2 &&
        _dialogCalendarPickerValue[0] != null &&
        _dialogCalendarPickerValue[1] != null);

    return Dialog(
      backgroundColor: AppColors.primaryColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        //  width: 350, // Fixed width for dialog look
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header Row (Date Text + Close Button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateRange(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Quick Select Chips ("Last 7 days", etc.)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickSelectChip("Last 7 days", 7),
                  const SizedBox(width: 8),
                  _buildQuickSelectChip("Last 14 days", 14),
                  const SizedBox(width: 8),
                  _buildQuickSelectChip("Last 30 days", 30),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. The Calendar Widget
            CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                centerAlignModePicker: true,
                disableModePicker: true,
                controlsTextStyle: Theme.of(context).textTheme.bodyLarge!
                    .copyWith(color: AppColors.secondaryColor),
                lastMonthIcon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.secondaryColor,
                ),
                nextMonthIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondaryColor,
                ),
                calendarType: CalendarDatePicker2Type.range,
                selectedDayHighlightColor: AppColors.greyAccentColor,
                selectedRangeHighlightColor: AppColors.middleGreyColor,
                daySplashColor: Colors.transparent,
                dayTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.secondaryColor,
                ),
                selectedDayTextStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
                weekdayLabels: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
                weekdayLabelTextStyle: Theme.of(context).textTheme.bodyLarge!
                    .copyWith(color: AppColors.secondaryColor),
                controlsHeight: 50,
                dayBorderRadius: BorderRadius.circular(50),
              ),
              value: _dialogCalendarPickerValue,
              onValueChanged: (dates) =>
                  setState(() => _dialogCalendarPickerValue = dates),
            ),
            const SizedBox(height: 16),

            // 4. "Done" Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isDateSet
                    ? () {
                        // Return the result to the parent
                        if (_dialogCalendarPickerValue.length == 2 &&
                            _dialogCalendarPickerValue[0] != null &&
                            _dialogCalendarPickerValue[1] != null) {
                          Navigator.pop(
                            context,
                            DateTimeRange(
                              start: _dialogCalendarPickerValue[0]!,
                              end: _dialogCalendarPickerValue[1]!,
                            ),
                          );
                        } else {
                          // Handle case where range isn't fully selected (optional)
                          Navigator.pop(context);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryColor, // AppColors.primaryColor
                  foregroundColor: AppColors.secondaryColor,
                  disabledForegroundColor: AppColors.filterTextColor,
                  disabledBackgroundColor: AppColors.filterFillColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: isDateSet
                          ? AppColors.secondaryColor
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Quick Select Chips
  Widget _buildQuickSelectChip(String label, int days) {
    return ActionChip(
      label: Text(label),
      backgroundColor: AppColors.filterFillColor,
      labelStyle: Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(color: AppColors.secondaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.filterBorderColor),
      ),
      onPressed: () => _selectQuickDateRange(days),
    );
  }

  // Helper to display formatted date text in header
  String _formatDateRange() {
    if (_dialogCalendarPickerValue.isEmpty ||
        _dialogCalendarPickerValue[0] == null) {
      return "Select dates";
    }
    final start = DateFormat('MMM d').format(_dialogCalendarPickerValue[0]!);
    String end = "";
    if (_dialogCalendarPickerValue.length > 1 &&
        _dialogCalendarPickerValue[1] != null) {
      end = " - ${DateFormat('MMM d').format(_dialogCalendarPickerValue[1]!)}";
    }
    return "$start$end";
  }
}
