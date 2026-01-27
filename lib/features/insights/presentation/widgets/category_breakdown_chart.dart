import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/features/insights/data/models/category_summary.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final List<CategorySummary> categories;
  final Function(String categoryName) onCategoryTap;

  const CategoryBreakdownChart({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    const double sectionThickness = 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. THE HALF DONUT CHART
        LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final double outerRadius = availableWidth / 2;
            final double centerRadius = outerRadius - sectionThickness;

            return SizedBox(
              height: outerRadius, // ✅ Exact height of the top half only
              width: availableWidth,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior:
                    Clip.none, // ✅ Allow the ghost slice to hang out bottom
                children: [
                  // THE CHART (Positioned to overflow)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    // Force chart to be a square based on WIDTH, ignoring the half-height container
                    height: availableWidth,
                    child: IgnorePointer(
                      // ✅ Prevents invisible bottom half from blocking list clicks
                      child: PieChart(
                        PieChartData(
                          startDegreeOffset: 180,
                          sectionsSpace: 2,
                          centerSpaceRadius: centerRadius,
                          sections: _buildChartSections(
                            radius: sectionThickness,
                            grandTotal: _calculateGrandTotal(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // // CENTER TEXT (Aligned to the baseline of the arch)
                  // Padding(
                  //   padding: EdgeInsets.only(bottom: outerRadius / 4),
                  //   child: Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Text(
                  //         "Top",
                  //         style: Theme.of(context).textTheme.bodySmall!
                  //             .copyWith(
                  //               color: AppColors.filterTextColor,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //       ),
                  //       Text(
                  //         categories.length > 4
                  //             ? '4'
                  //             : categories.length.toString(),
                  //         style: const TextStyle(
                  //           fontWeight: FontWeight.w900,
                  //           fontSize: 32,
                  //           height: 1.0, // Tighter line height
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24), // Clean spacing between arch and list
        Text(
          'Categories',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: AppColors.secondaryColor),
        ),
        const SizedBox(height: 10), // Clean spacing between arch and list
        // 2. THE LIST VIEW (Unchanged)
        // ...categories.map((cat) {
        //   return GestureDetector(
        //     onTap: () => onCategoryTap(cat.name),
        //     child: Padding(
        //       padding: const EdgeInsets.only(bottom: 16.0),
        //       child: Row(
        //         children: [
        //           Container(
        //             padding: const EdgeInsets.all(10),
        //             decoration: BoxDecoration(
        //               color: cat.color.withOpacity(0.1),
        //               shape: BoxShape.circle,
        //             ),
        //             child: Icon(cat.icon, color: cat.color, size: 18),
        //           ),
        //           const SizedBox(width: 12),
        //           Expanded(
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   children: [
        //                     Expanded(
        //                       child: Text(
        //                         cat.name,
        //                         overflow: TextOverflow.ellipsis,
        //                         style: const TextStyle(
        //                           fontWeight: FontWeight.bold,
        //                         ),
        //                       ),
        //                     ),
        //                     Text(
        //                       '₦${NumberFormat.currency(symbol: '', decimalDigits: 0).format(cat.totalAmount)}',
        //                       style: const TextStyle(
        //                         fontWeight: FontWeight.bold,
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //                 const SizedBox(height: 6),
        //                 ClipRRect(
        //                   borderRadius: BorderRadius.circular(4),
        //                   child: LinearProgressIndicator(
        //                     value: cat.percentage,
        //                     backgroundColor: AppColors.thinTwoGreyColor,
        //                     color: cat.color,
        //                     minHeight: 6,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           const SizedBox(width: 12),
        //           Text(
        //             '${(cat.percentage * 100).toStringAsFixed(0)}%',
        //             style: TextStyle(
        //               color: Colors.grey.shade600,
        //               fontWeight: FontWeight.bold,
        //               fontSize: 12,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   );
        // }),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.thinTwoGreyColor, // ✅ The Background Color
            borderRadius: BorderRadius.circular(20), // Rounded corners
            // border: Border.all(color: Colors.grey.shade200), // Optional Border
          ),
          child: Column(
            children: categories.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              final isLast = index == categories.length - 1;

              return GestureDetector(
                onTap: () => onCategoryTap(cat.name),
                behavior: HitTestBehavior
                    .opaque, // Ensures clicks work on the whole row
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              // color: Colors
                              //     .white, // White icon bg looks clean on grey
                              color: cat.color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat.icon,
                              color: AppColors.primaryColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cat.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: AppColors.secondaryColor,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                // ClipRRect(
                                //   borderRadius: BorderRadius.circular(4),
                                //   child: LinearProgressIndicator(
                                //     value: cat.percentage,
                                //     // Make track white to stand out on grey bg
                                //     backgroundColor: Colors.white,
                                //     color: cat.color,
                                //     minHeight: 6,
                                //   ),
                                // ),
                                Text(
                                  '₦${NumberFormat.currency(symbol: '', decimalDigits: 0).format(cat.totalAmount)}',
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(color: AppColors.greyTextColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(cat.percentage * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: AppColors.greyTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.greyTextColor,
                            size: 10,
                          ),
                        ],
                      ),
                    ),
                    // Optional: Add separator line if not the last item
                    if (!isLast)
                      Divider(height: 1, color: Colors.grey.shade300),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  double _calculateGrandTotal() {
    return categories.fold(0, (sum, item) => sum + item.totalAmount);
  }

  List<PieChartSectionData> _buildChartSections({
    required double radius,
    required double grandTotal,
  }) {
    List<PieChartSectionData> sections = [];

    // 1. Top Categories
    int count = 0;
    for (var cat in categories) {
      if (count >= 4) break;
      sections.add(
        PieChartSectionData(
          color: cat.color,
          value: cat.totalAmount,
          title: '',
          radius: radius,
          showTitle: false,
        ),
      );
      count++;
    }

    // 2. Others
    if (categories.length > 4) {
      double otherTotal = 0;
      for (int i = 4; i < categories.length; i++) {
        otherTotal += categories[i].totalAmount;
      }
      sections.add(
        PieChartSectionData(
          color: AppColors.filterTextColor.withOpacity(0.5),
          value: otherTotal,
          title: '',
          radius: radius,
          showTitle: false,
        ),
      );
    }

    // 3. Ghost Slice
    sections.add(
      PieChartSectionData(
        color: Colors.transparent,
        value: grandTotal,
        title: '',
        radius: radius,
        showTitle: false,
      ),
    );

    return sections;
  }
}
