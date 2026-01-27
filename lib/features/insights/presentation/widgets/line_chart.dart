// import 'dart:math';

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';

// class SpendingTrendChart extends StatelessWidget {
//   final List<FlSpot> spots;
//   final bool isDailyView;
//   final double maxY;
//   final DateTime startDate;
//   final int durationInDays;

//   const SpendingTrendChart({
//     super.key,
//     required this.spots,
//     required this.isDailyView,
//     required this.maxY,
//     required this.startDate,
//     required this.durationInDays,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // 1. Calculations
//     final double effectiveMaxY = (maxY == 0) ? 5000 : maxY;
//     final double yInterval = _calculateYAxisInterval(effectiveMaxY);
//     final double adjustedMaxY = ((effectiveMaxY / yInterval).ceil() * yInterval)
//         .toDouble();

//     // Max X Index (e.g., if 30 days, indices are 0 to 29)
//     final double maxX = isDailyView ? 23 : (durationInDays - 1).toDouble();

//     // 2. Pre-Calculate which X-labels to show (The "Smart Steps" logic)
//     final Set<int> visibleXIndices = _calculateVisibleXIndices(maxX.toInt());

//     return LineChart(
//       LineChartData(
//         // Tooltips (Keep existing logic)
//         lineTouchData: LineTouchData(
//           handleBuiltInTouches: true,
//           touchTooltipData: LineTouchTooltipData(
//             tooltipBgColor: AppColors.primaryColor,
//             tooltipRoundedRadius: 8,
//             getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
//               return touchedBarSpots.map((barSpot) {
//                 return LineTooltipItem(
//                   '₦${_formatCompactMoney(barSpot.y)}',
//                   TextStyle(
//                     color: AppColors.secondaryColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 );
//               }).toList();
//             },
//           ),
//         ),

//         // Grid (Only horizontal lines for a cleaner look)
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: yInterval,
//           getDrawingHorizontalLine: (value) => FlLine(
//             color: AppColors.greyishColor.withOpacity(0.5),
//             strokeWidth: 1,
//             dashArray: [5, 5],
//           ),
//         ),

//         titlesData: FlTitlesData(
//           show: true,
//           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

//           // Y-AXIS (Money)
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 40,
//               interval: yInterval,
//               getTitlesWidget: (value, meta) {
//                 if (value == 0) return const SizedBox.shrink();
//                 return SideTitleWidget(
//                   axisSide: meta.axisSide,
//                   child: Text(
//                     _formatCompactMoney(value),
//                     style: TextStyle(
//                       color: AppColors.greyTextColor,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // X-AXIS (THE PROFESSIONAL FIX)
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 30,
//               // We check every index (1), but hide the ones we don't want in the widget builder
//               interval: 1,
//               getTitlesWidget: (value, meta) {
//                 int index = value.toInt();

//                 // 1. Filter: Only show the specific indices we calculated
//                 if (!visibleXIndices.contains(index)) {
//                   return const SizedBox.shrink();
//                 }

//                 // 2. Render Text
//                 return SideTitleWidget(
//                   axisSide: meta.axisSide,
//                   // ✅ KEY FIX: Prevents First/Last labels from being cut off screen
//                   fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       _getBottomLabel(index),
//                       style: TextStyle(
//                         color: AppColors.greyAccentColor,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),

//         borderData: FlBorderData(show: false),

//         // Scaling
//         minX: 0,
//         maxX: maxX,
//         minY: 0,
//         maxY: adjustedMaxY,

//         // Line Data
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             isCurved: true,
//             color: AppColors.filterTextColor,
//             barWidth: 2,
//             isStrokeCapRound: true,
//             dotData: FlDotData(show: false),
//             belowBarData: BarAreaData(
//               show: true,
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.filterFillColor,
//                   AppColors.secondaryColor.withOpacity(0.0),
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- THE "3-LABEL" CALCULATOR ---
//   // Returns exactly 3 indices: First, Middle, Last
//   Set<int> _calculateVisibleXIndices(int maxIndex) {
//     Set<int> indices = {};

//     if (isDailyView) {
//       // Daily: Keep showing standard 6-hour intervals (0, 6, 12, 18)
//       // or change this to {0, 12, 23} if you want the 3-label rule here too.
//       indices = {0, 6, 12, 18, 23};
//     } else {
//       // Date Range: The "First - Middle - Last" Rule

//       // 1. The First Day
//       indices.add(0);

//       // 2. The Last Day
//       indices.add(maxIndex);

//       // 3. The Middle Day (only if we have at least 3 days)
//       if (maxIndex >= 2) {
//         int middleIndex = (maxIndex / 2).round();
//         indices.add(middleIndex);
//       }
//     }
//     return indices;
//   }

//   // --- 2. FORMATTING HELPERS ---
//   String _getBottomLabel(int index) {
//     if (isDailyView) {
//       if (index == 0) return '12 AM';
//       if (index == 12) return '12 PM';
//       if (index > 12) return '${index - 12} PM';
//       return '$index AM';
//     } else {
//       final date = startDate.add(Duration(days: index));

//       // Smart Format: If it's the start of a year, show Year.
//       // If it's the 1st of a month, show Month Name.
//       // Otherwise show Month+Day
//       if (index == 0 && durationInDays > 60) {
//         return DateFormat('MMM d').format(date);
//       }
//       return DateFormat('MMM d').format(date);
//     }
//   }

//   String _formatCompactMoney(double value) {
//     if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
//     if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
//     return value.toStringAsFixed(0);
//   }

//   double _calculateYAxisInterval(double max) {
//     if (max == 0) return 1000;
//     double rawStep = max / 4;
//     double magnitude = pow(10, (log(rawStep) / ln10).floor()).toDouble();
//     double normalizedStep = rawStep / magnitude;
//     double niceStep = (normalizedStep <= 1.0)
//         ? 1
//         : (normalizedStep <= 2.0 ? 2 : (normalizedStep <= 5.0 ? 5 : 10));
//     return niceStep * magnitude;
//   }
// }
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<FlSpot> spots;
  final bool isDailyView;
  final double maxY;
  final DateTime startDate;
  final int durationInDays;

  const SpendingTrendChart({
    super.key,
    required this.spots,
    required this.isDailyView,
    required this.maxY,
    required this.startDate,
    required this.durationInDays,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculations
    final double effectiveMaxY = (maxY == 0) ? 5000 : maxY;
    final double yInterval = _calculateYAxisInterval(effectiveMaxY);
    final double adjustedMaxY = ((effectiveMaxY / yInterval).ceil() * yInterval)
        .toDouble();

    // Max X Index
    final double maxX = isDailyView ? 23 : (durationInDays - 1).toDouble();

    // 2. Pre-Calculate Visible Indices
    final Set<int> visibleXIndices = _calculateVisibleXIndices(maxX.toInt());

    return LineChart(
      LineChartData(
        // Tooltips
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: AppColors.primaryColor,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  '₦${_formatCompactMoney(barSpot.y)}',
                  TextStyle(
                    color: AppColors.secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),

        // GRID LINES (Updated to match reference)
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true, // ✅ Enabled Vertical Lines
          horizontalInterval: yInterval,

          // Only show vertical lines where we have labels (Cleaner look)
          checkToShowVerticalLine: (value) =>
              visibleXIndices.contains(value.toInt()),
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.greyishColor.withOpacity(0.5),
            strokeWidth: 1.5, // Slightly thicker dashed line
            dashArray: [6, 4], // Longer dashes like the image
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: AppColors.greyishColor.withOpacity(
              0.2,
            ), // Faint vertical lines
            strokeWidth: 1,
          ),
        ),

        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

          // Y-AXIS
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _formatCompactMoney(value),
                    style: TextStyle(
                      color: AppColors.greyTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          // X-AXIS
          // X-AXIS
          // X-AXIS
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();

                // 1. Filter hidden indices
                if (!visibleXIndices.contains(index)) {
                  return const SizedBox.shrink();
                }

                // 2. LOGIC UPDATE: When to use strict grid spacing?
                // - If it's Daily View (Hours)
                // - OR If it's Weekly View (Single Letters)
                bool useStrictSpacing = isDailyView || durationInDays <= 7;

                return SideTitleWidget(
                  axisSide: meta.axisSide,

                  // ✅ THE FIX: Disable fitInside for both Daily & Weekly views
                  // This forces the text to sit EXACTLY on the grid line, ensuring equal spacing.
                  fitInside: useStrictSpacing
                      ? SideTitleFitInsideData.disable()
                      : SideTitleFitInsideData.fromTitleMeta(meta),

                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _getBottomLabel(index),
                      style: TextStyle(
                        color: AppColors.greyAccentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        wordSpacing: -5,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // bottomTitles: AxisTitles(
          //   sideTitles: SideTitles(
          //     showTitles: true,
          //     reservedSize: 30,
          //     interval: 1,
          //     getTitlesWidget: (value, meta) {
          //       int index = value.toInt();
          //       if (!visibleXIndices.contains(index)) {
          //         return const SizedBox.shrink();
          //       }

          //       return SideTitleWidget(
          //         axisSide: meta.axisSide,
          //         fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
          //         child: Padding(
          //           padding: const EdgeInsets.only(top: 8.0),
          //           child: Text(
          //             _getBottomLabel(index),
          //             style: TextStyle(
          //               color: AppColors.greyAccentColor,
          //               fontSize: 10,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ),

        borderData: FlBorderData(show: false),

        // Scaling
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: adjustedMaxY,

        // THE LINE (Updated to match reference)
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false, // ✅ FALSE: Makes the line angular/sharp
            color: const Color(
              0xFF004B8D,
            ), // Matches the dark blue in the image
            barWidth: 2, // Thicker line
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(
                0xFF004B8D,
              ).withOpacity(0.05), // Solid light blue fill
              // Or keep your gradient if you prefer:
              // gradient: LinearGradient(...),
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATED CALCULATOR ---
  Set<int> _calculateVisibleXIndices(int maxIndex) {
    Set<int> indices = {};

    if (isDailyView) {
      indices = {0, 6, 12, 18, 23};
    } else {
      // ✅ IF WEEKLY (7 days or less), show ALL days like the image
      if (maxIndex <= 6) {
        for (int i = 0; i <= maxIndex; i++) {
          indices.add(i);
        }
      } else {
        // Longer ranges: Use the "First - Middle - Last" Rule
        indices.add(0);
        indices.add(maxIndex);
        if (maxIndex >= 2) {
          int middleIndex = (maxIndex / 2).round();
          indices.add(middleIndex);
        }
      }
    }
    return indices;
  }

  // --- HELPERS (Unchanged) ---
  // String _getBottomLabel(int index) {
  //   if (isDailyView) {
  //     if (index == 0) return '12 AM';
  //     if (index == 12) return '12 PM';
  //     if (index > 12) return '${index - 12} PM';
  //     return '$index AM';
  //   } else {
  //     final date = startDate.add(Duration(days: index));
  //     // Optional: Return just the day letter (S, M, T) if you want an exact match
  //     // return DateFormat('E').format(date)[0];
  //     return DateFormat('MMM d').format(date);
  //   }
  // }
  String _getBottomLabel(int index) {
    if (isDailyView) {
      // HOURLY VIEW (12 AM - 11 PM)
      if (index == 0) return '12 AM';
      if (index == 12) return '12 PM';
      if (index > 12) return '${index - 12} PM';
      return '$index AM';
    } else {
      final date = startDate.add(Duration(days: index));

      // ✅ NEW: If range is 7 days or less, show Single Letter (M, T, W...)
      if (durationInDays <= 7) {
        // DateFormat('E') returns "Mon", "Tue". We take the 1st letter.
        return DateFormat('E').format(date)[0];
      }

      // LONG RANGE VIEW (Jan 1, Jan 5...)
      // Smart Format: If it's a very long range, emphasize the first date
      if (index == 0 && durationInDays > 60) {
        return DateFormat('MMM d').format(date);
      }
      return DateFormat('MMM d').format(date);
    }
  }

  String _formatCompactMoney(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
  }

  double _calculateYAxisInterval(double max) {
    if (max == 0) return 1000;
    double rawStep = max / 4;
    double magnitude = pow(10, (log(rawStep) / ln10).floor()).toDouble();
    double normalizedStep = rawStep / magnitude;
    double niceStep = (normalizedStep <= 1.0)
        ? 1
        : (normalizedStep <= 2.0 ? 2 : (normalizedStep <= 5.0 ? 5 : 10));
    return niceStep * magnitude;
  }
}
