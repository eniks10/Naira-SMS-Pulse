import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/core/config/asset/app_icons.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/activity/presentation/widgets/custom_data_range_picker.dart';
import 'package:naira_sms_pulse/features/insights/presentation/bloc/insight_bloc.dart';
import 'package:naira_sms_pulse/features/insights/presentation/bloc/insight_state.dart';
import 'package:naira_sms_pulse/features/insights/presentation/pages/transaction_category_list_page.dart';
import 'package:naira_sms_pulse/features/insights/presentation/widgets/category_breakdown_chart.dart';
import 'package:naira_sms_pulse/features/insights/presentation/widgets/line_chart.dart';

class InsightsPage extends StatefulWidget {
  static const String routeName = 'insights_page';
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  DateTimeRange getThisWeek() {
    final now = DateTime.now();

    // 1. Calculate Start (Monday)
    // now.weekday gives 1 for Mon, 7 for Sun.
    // We subtract (weekday - 1) to get back to Monday.
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    // 2. Calculate End (Sunday)
    // We add 6 days to Monday to get Sunday.
    // We set the time to 23:59:59 to include the whole last day.
    final end = start.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    return DateTimeRange(start: start, end: end);
  }

  @override
  void initState() {
    super.initState();

    context.read<InsightBloc>().add(
      //SetDateFilterEvent(timeRange: getThisWeek()),
      LoadTransactions(timeRange: getThisWeek()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InsightBloc, InsightState>(
      listener: (context, state) {},
      builder: (context, state) {
        // 1. Calculate Total Spend safely
        final double totalSpent = state.categorySummary.fold(
          0,
          (sum, item) => sum + item.totalAmount,
        );

        // 2. Check if we have data
        final bool hasData = state.maxAmount > 0;
        final spots = state.graphSpots.isEmpty
            ? [
                const FlSpot(0, 0),
                const FlSpot(23, 0),
              ] // Fallback to avoid crash
            : state.graphSpots;
        final int totalDays =
            state.timeRange.end.difference(state.timeRange.start).inDays + 1;

        String totalTitle = state.selectedType == TransactionType.debit
            ? "Expenses"
            : "Inflow";
        return Scaffold(
          backgroundColor: AppColors.primaryColor,

          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10),

                _buildHeader(context),
                SizedBox(height: 10),
                _buildFilterButtons(context, state),
                const SizedBox(height: 16),
                // ✅ ADD THE TOGGLE HERE
                _buildTypeToggle(context, state),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => context.read<InsightBloc>().add(
                      //SetDateFilterEvent(timeRange: state.timeRange),
                      LoadTransactions(timeRange: getThisWeek()),
                    ),
                    color: AppColors.secondaryColor,
                    backgroundColor: AppColors.primaryColor,
                    child: CustomScrollView(
                      slivers: [
                        // SECTION 1: THE HERO (Total Spend)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Column(
                              children: [
                                Text(
                                  totalTitle, // ✅ Use dynamic title
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.greyTextColor,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₦${NumberFormat.currency(symbol: '', decimalDigits: 0).format(totalSpent)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight:
                                            FontWeight.w900, // Very bold
                                        color: Colors.black,
                                        fontSize: 32,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.35,
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            // decoration: BoxDecoration(
                            //   // color:
                            //   //     AppColors.thinTwoGreyColor, // Subtle background
                            //   borderRadius: BorderRadius.circular(24),
                            // ),
                            decoration: BoxDecoration(
                              color: AppColors.filterFillColor.withOpacity(
                                0.3,
                              ), // Very subtle fill
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.thinTwoGreyColor,
                              ),
                            ),
                            child: hasData
                                ? SpendingTrendChart(
                                    spots: spots,
                                    isDailyView: state.isDailyView,
                                    maxY: state.maxAmount,
                                    startDate: state.timeRange.start,
                                    durationInDays: state.isDailyView
                                        ? 1
                                        : totalDays,
                                  )
                                : _buildEmptyState(),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasData) ...[
                                  Text(
                                    //textAlign: TextAlign.center,
                                    "Where your money went",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(),
                                  ),
                                  const SizedBox(height: 10),
                                  CategoryBreakdownChart(
                                    categories: state.categorySummary,
                                    onCategoryTap: (categoryName) {
                                      // final categoryTransactions = state
                                      //     .transactions
                                      //     .where(
                                      //       (txn) =>
                                      //           (txn.categoryName) ==
                                      //           categoryName,
                                      //     )
                                      //     .toList();

                                      Navigator.pushNamed(
                                        context,
                                        CategoryTransactionsPage.routeName,
                                        arguments: {
                                          'categoryName': categoryName,
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ New Clean Empty State Widget
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bar_chart_rounded, size: 64, color: AppColors.thinGreyColor),
        const SizedBox(height: 12),
        Text(
          "No spending activity",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.greyTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          textAlign: TextAlign.center,
          "Transactions in this period will appear here.",
          style: TextStyle(color: AppColors.greyTextColor, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _pickDateRange(BuildContext context, int index) async {
    final state = context.read<InsightBloc>().state;
    // Open the Date Range Picker
    final DateTimeRange? result = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) =>
          CustomDateRangePicker(initialDateRange: state.timeRange),
    );
    if (result != null) {
      // ✅ Trigger the Bloc Event
      if (context.mounted) {
        print(result);

        context.read<InsightBloc>().add(
          // SetDateFilterEvent(timeRange: result)
          SetFilterEvent(index: index, timeRange: result),
        );
      }
    }
  }

  String _formatSmartRange(DateTime start, DateTime end) {
    final fullFormat = DateFormat('MMMM d'); // "January 26"

    // 1. ✅ CHECK FOR SAME DAY
    // If year, month, and day are all the same, just return "January 26"
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return fullFormat.format(start);
    }

    // 2. HANDLE RANGES
    final monthFormat = DateFormat('MMMM');
    final dayFormat = DateFormat('d');

    if (start.month == end.month && start.year == end.year) {
      // Same Month Range: "January 13 - 15"
      return '${monthFormat.format(start)} ${dayFormat.format(start)} - ${dayFormat.format(end)}';
    } else {
      // Different Months Range: "January 30 - February 2"
      return '${fullFormat.format(start)} - ${fullFormat.format(end)}';
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.horizontal(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            // _getGreeting(),
            'Insights',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.secondaryColor,
              // wordSpacing: -5,
              //letterSpacing: -1,
            ),
          ),

          Spacer(),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(BuildContext context, InsightState state) {
    String dateLabel = state.timeRange == getThisWeek()
        ? 'This Week'
        : _formatSmartRange(state.timeRange.start, state.timeRange.end);

    String accountLabel = 'All Accounts';
    if (state.selectedBankIndex != 0) {
      accountLabel = state.myBanks[state.selectedBankIndex - 1].name;
    }

    final labels = [dateLabel, accountLabel];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.horizontal(context),
        ),
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          // final isFilterActive =
          //     (index == 0 && state.dateTimeRange != null) ||
          //     (index == 1 &&
          //         state.categoryFilters != null &&
          //         state.categoryFilters!.isNotEmpty) ||
          //     (index == 2 && state.selectedbank != null);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              // Highlight color if active
              color:
                  // isFilterActive
                  //     ? AppColors.secondaryColor.withOpacity(0.1)
                  //     :
                  AppColors.filterFillColor,
              // border: Border.all(
              //   color:
              //       //  isFilterActive
              //       //     ? AppColors.secondaryColor
              //       //     :
              //       AppColors.filterBorderColor,
              // ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (index == 0) _pickDateRange(context, index);

                    if (index == 1) {
                      _showBankFilterDialog(context, state, index);
                    }
                  },
                  child: Text(
                    labels[index],
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color:
                          //  isFilterActive
                          //     ? AppColors.secondaryColor
                          //     :
                          AppColors.filterTextColor,
                      fontWeight:
                          // isFilterActive
                          //     ? FontWeight.bold
                          //     :
                          FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  // isFilterActive
                  //     ? AppIcons.cancelIcon
                  //     :
                  AppIcons.dropDownArrowIcon,
                  height: 16,
                  width: 16,
                  colorFilter: ColorFilter.mode(
                    // isFilterActive
                    //     ? AppColors.secondaryColor
                    //     :
                    AppColors.filterTextColor,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBankFilterDialog(
    BuildContext context,
    InsightState state,
    int filterIndex,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter, // Forces the dialog to the bottom
          child: Container(
            // MARGINS: This creates the "gap" from the bottom and sides
            margin: const EdgeInsets.only(bottom: 24, left: 12, right: 12),

            // DECORATION: This gives you the curved bottom and top
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(20), // Curves all corners
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.2),
              //     blurRadius: 10,
              //     offset: const Offset(0, 5),
              //   ),
              // ],
            ),

            // CONTENT
            child: Material(
              color: Colors.transparent, // Keeps the ripple effect working
              child: Padding(
                padding: EdgeInsets.all(Dimensions.horizontal(context)),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Shrinks to fit content
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Account",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: AppColors.secondaryColor),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.thinGreyColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              AppIcons.cancelIcon,
                              height: 20,
                              width: 20,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.myBanks.length + 1,
                      itemBuilder: (context, index) {
                        bool isAllAccounts = index == 0;

                        // Logic: If index is 0, bank is null. Else, shift index by 1.
                        final bank = isAllAccounts
                            ? null
                            : state.myBanks[index - 1];

                        // Check if this row is selected
                        bool isSelected = state.selectedBankIndex == index;

                        return GestureDetector(
                          onTap: () {
                            context.read<InsightBloc>().add(
                              SetFilterEvent(
                                index: filterIndex,
                                selectedbankIndex: index,
                                selectedBank: bank,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            // MARGIN: Adds space between the list items
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.thinGreyColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              // Optional: Add a subtle border to unselected items for better structure
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // Aligns text and icon vertically
                              children: [
                                // --- UNIFIED ICON CONTAINER ---
                                // We enforce a strict 40x40 box here.
                                // This guarantees every row starts with the exact same shape.
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.greyishColor,
                                    shape: BoxShape.circle,
                                  ),
                                  // Center the icon/image inside this 40x40 box
                                  alignment: Alignment.center,
                                  child: isAllAccounts
                                      ? Icon(
                                          Icons.account_balance,
                                          size: 20,
                                          color: AppColors.secondaryColor,
                                        )
                                      : _buildBankLogo(bank?.logoUrl),
                                ),

                                const SizedBox(width: 14),

                                // --- NAME TEXT ---
                                // Expanded ensures text doesn't overflow if the name is long
                                Expanded(
                                  child: Text(
                                    isAllAccounts
                                        ? "All Accounts"
                                        : bank?.name ?? "Unknown Bank",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: AppColors.secondaryColor,
                                          fontWeight: FontWeight.bold,
                                          height:
                                              1.2, // Fixes vertical alignment of text
                                        ),
                                    overflow: TextOverflow
                                        .ellipsis, // Adds "..." if text is too long
                                  ),
                                ),

                                // OPTIONAL: Add a checkmark if selected
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: AppColors.secondaryColor,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBankLogo(String? url) {
    // Case 1: No URL provided -> Show Fallback Icon
    if (url == null || url.isEmpty) {
      return Icon(
        Icons.account_balance,
        size: 20,
        color: AppColors.greyTextColor,
      );
    }

    // Case 2: URL exists -> Show Image clipped to a Circle
    return ClipOval(
      child: SvgPicture.network(
        url,
        height: 40, // Force fit to parent
        width: 40, // Force fit to parent
        fit: BoxFit.cover, // Ensures image fills the circle without distortion
        placeholderBuilder: (_) => Icon(
          Icons.account_balance,
          size: 20,
          color: AppColors.greyTextColor,
        ),
        // Note: If you are using local assets instead of network,
        // swap .network() for .asset() and remove the 'url' parameter.
      ),
    );
  }

  Widget _buildTypeToggle(BuildContext context, InsightState state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.horizontal(context)),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.filterFillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleBtn(
            context,
            "Expense",
            TransactionType.debit,
            state.selectedType,
          ),
          _buildToggleBtn(
            context,
            "Income",
            TransactionType.credit,
            state.selectedType,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(
    BuildContext context,
    String label,
    TransactionType type,
    TransactionType currentType,
  ) {
    final isSelected = type == currentType;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            context.read<InsightBloc>().add(SetTransactionTypeEvent(type));
          }
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
