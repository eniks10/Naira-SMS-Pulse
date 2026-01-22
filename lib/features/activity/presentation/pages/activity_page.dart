import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/core/config/asset/app_icons.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:naira_sms_pulse/features/activity/presentation/bloc/activity_state.dart';
import 'package:naira_sms_pulse/features/activity/presentation/widgets/custom_data_range_picker.dart';
import 'package:naira_sms_pulse/features/home/presentation/pages/transaction_details_page.dart';
import 'package:naira_sms_pulse/features/home/presentation/widgets/transaction_tile.dart';

class ActivityPage extends StatefulWidget {
  static const routeName = 'activity_page';
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  void initState() {
    super.initState();
    context.read<ActivityBloc>().add(LoadTransactions());
  }

  final List<String> _filters = ['Date', 'Category', 'Account'];
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityBloc, ActivityState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                SizedBox(height: Dimensions.medium),
                //Filter Buttons
                _buildFilterButtons(context, state),

                SizedBox(height: Dimensions.medium),
                // Expanded(
                //   child: RefreshIndicator(
                //     onRefresh: () async {},
                //     color: AppColors.secondaryColor,
                //     backgroundColor: AppColors.primaryColor,
                //     child: CustomScrollView(
                //       // This ensures you can pull-to-refresh even if the list is empty!
                //       physics: const AlwaysScrollableScrollPhysics(
                //         parent: BouncingScrollPhysics(),
                //       ),
                //       slivers: [
                //         if (state.transactions.isEmpty)
                //           SliverFillRemaining(
                //             child: Center(
                //               child: Column(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   Icon(
                //                     Icons.filter_list_off_rounded,
                //                     size: 64,
                //                     color: AppColors.greyishColor,
                //                   ),
                //                   SizedBox(height: 16),
                //                   Text(
                //                     "No transactions\nfound.",
                //                     textAlign: TextAlign.center,
                //                     style: Theme.of(context)
                //                         .textTheme
                //                         .displaySmall!
                //                         .copyWith(
                //                           color: AppColors.greyAccentColor,
                //                           fontSize: 25,
                //                           fontWeight: FontWeight.bold,
                //                         ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         SliverList.builder(
                //           itemCount: state.transactions.length,
                //           itemBuilder: (context, index) {
                //             final txn = state.transactions[index];
                //             final icon =
                //                 state.categoryIcons[txn.categoryName] ??
                //                 Icons.category_rounded;
                //             return TransactionTile(
                //               transaction: txn,
                //               categoryIcon: icon,
                //             );
                //           },
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Expanded(child: _buildTransactionList(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterCategoryDialog(BuildContext context, int index) {
    final screenHeight = MediaQuery.of(context).size.height;
    final state = context.read<ActivityBloc>().state;

    // 1. DEFINE THE LISTS
    final categoryList = state.myCategories;
    const incomeCategories = ['Taxable Income', 'Non-Taxable Income'];

    final expenseCategories = categoryList
        .where((category) => !incomeCategories.contains(category))
        .toList();

    final Set<String> tempSelectedFilters = (state.categoryFilters ?? [])
        .toSet();

    print(state.categoryFilters);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // CONSTRAINTS: Max 50% screen height
                constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
                margin: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.all(Dimensions.horizontal(context)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Shrinks to fit content
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. HEADER ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sort by Category',

                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(color: AppColors.secondaryColor),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.thinGreyColor,
                                ),
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

                        const SizedBox(height: 5),
                        Divider(color: AppColors.greyishColor),
                        const SizedBox(height: 10),

                        // --- 2. SCROLLABLE LIST ---
                        // Flexible takes up remaining space, but shrinks for the button below
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expenses',

                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color: AppColors.secondaryColor,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  // children: state.categoryNames.map((category) {
                                  children: expenseCategories.map((category) {
                                    // final isSelected =
                                    //     category == transaction.categoryName;
                                    final isSelected = tempSelectedFilters
                                        .contains(category);

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            tempSelectedFilters.remove(
                                              category,
                                            );
                                          } else {
                                            tempSelectedFilters.add(category);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.secondaryColor
                                                    .withOpacity(0.1)
                                              : AppColors.whitishGreyTextColor,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.secondaryColor
                                                : AppColors.thinGreyColor,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          category,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: isSelected
                                                    ? AppColors.secondaryColor
                                                    : AppColors.secondaryColor
                                                          .withOpacity(0.8),
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  'Income',

                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color: AppColors.secondaryColor,
                                      ),
                                ),
                                const SizedBox(height: 10),

                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  // children: state.categoryNames.map((category) {
                                  children: incomeCategories.map((category) {
                                    // final isSelected =
                                    //     category == transaction.categoryName;
                                    final isSelected = tempSelectedFilters
                                        .contains(category);

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            tempSelectedFilters.remove(
                                              category,
                                            );
                                          } else {
                                            tempSelectedFilters.add(category);
                                          }
                                        });
                                      },

                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.whitishGreyTextColor,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.secondaryColor
                                                : AppColors.thinGreyColor,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          category,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: isSelected
                                                    ? AppColors.secondaryColor
                                                    : AppColors.secondaryColor
                                                          .withOpacity(0.8),
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20), // Spacing before button
                        // --- 3. ADD CATEGORY BUTTON ---
                        SizedBox(
                          width: double.infinity,
                          height: Dimensions.smallbuttonHeight,
                          child: OutlinedButton(
                            onPressed: tempSelectedFilters.isNotEmpty
                                ? () {
                                    // Close this selection dialog first
                                    // Navigator.pop(context);

                                    context.read<ActivityBloc>().add(
                                      SetDateFilterEvent(
                                        index: index,
                                        selectedCategory: tempSelectedFilters
                                            .toList(),
                                      ),
                                    );

                                    Navigator.pop(context);
                                    print(state.categoryFilters);

                                    // Then open the "Add New" dialog
                                    //_showAddCategorySheet();
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              // side: BorderSide(color: AppColors.secondaryColor),
                              // backgroundColor: AppColors.primaryColor,
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(12),
                              // ),
                              backgroundColor: AppColors
                                  .primaryColor, // AppColors.primaryColor
                              foregroundColor: AppColors.secondaryColor,
                              disabledForegroundColor:
                                  AppColors.filterTextColor,
                              disabledBackgroundColor:
                                  AppColors.filterFillColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                  color: tempSelectedFilters.isNotEmpty
                                      ? AppColors.secondaryColor
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            child: Text(
                              'Done', // Changed text
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: AppColors.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBankFilterDialog(BuildContext context, int indexx) {
    final state = context.read<ActivityBloc>().state;
    final myBankList = state.myBanks;
    print(myBankList);

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
                          "Sort by Account",
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: SvgPicture.asset(
                                AppIcons.cancelIcon,
                                height: 20,
                                width: 20,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: myBankList.length,
                      itemBuilder: (context, index) {
                        // bool isAllAccounts = index == 0;

                        // // Logic: If index is 0, bank is null. Else, shift index by 1.
                        // final bank = isAllAccounts
                        //     ? null
                        //     : state.selectedbanks[index - 1];

                        // // Check if this row is selected
                        // bool isSelected = state.selectedBankIndex == index;

                        final bool isSelected =
                            state.selectedBankIndex == index;

                        final bank = myBankList[index];

                        return GestureDetector(
                          onTap: () {
                            context.read<ActivityBloc>().add(
                              SetDateFilterEvent(
                                index: indexx,
                                selectedBank: bank,
                                selectedbankIndex: index,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            // MARGIN: Adds space between the list items
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              // Optional: Add a subtle border to unselected items for better structure
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.secondaryColor
                                    : Colors.grey.withOpacity(0.1),
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
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.filterBorderColor,
                                    ),
                                  ),
                                  // Center the icon/image inside this 40x40 box
                                  alignment: Alignment.center,
                                  child:
                                      // isAllAccounts
                                      //     ? Icon(
                                      //         Icons.account_balance,
                                      //         size: 20,
                                      //         color: AppColors.secondaryColor,
                                      //       )
                                      //     :
                                      _buildBankLogo(bank?.logoUrl),
                                ),

                                const SizedBox(width: 14),

                                // --- NAME TEXT ---
                                // Expanded ensures text doesn't overflow if the name is long
                                Expanded(
                                  child: Text(
                                    // isAllAccounts
                                    //     ? "All Accounts"
                                    //     :
                                    bank?.name ?? "Unknown Bank",
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
                                // if (isSelected)
                                //   Icon(
                                //     Icons.check_circle,
                                //     size: 20,
                                //     color: AppColors.secondaryColor,
                                //   ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.horizontal(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            // _getGreeting(),
            'Activity',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.secondaryColor,
              // wordSpacing: -5,
              //letterSpacing: -1,
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search_rounded,
              size: 25,
              color: AppColors.greyTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(BuildContext context, ActivityState state) {
    String dateLabel = 'Date';
    if (state.dateTimeRange != null) {
      dateLabel = _formatSmartRange(
        state.dateTimeRange!.start,
        state.dateTimeRange!.end,
      );
    }

    String categoryLabel = 'Category';
    if (state.categoryFilters != null && state.categoryFilters!.isNotEmpty) {
      if (state.categoryFilters!.length > 1) {
        categoryLabel = "${state.categoryFilters!.length} Categories";
      } else {
        categoryLabel = state.categoryFilters!.first;
      }
    }

    String accountLabel = 'Account';
    if (state.selectedbank != null) {
      accountLabel = state.selectedbank!.name;
    }

    final labels = [dateLabel, categoryLabel, accountLabel];

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
          final isFilterActive =
              (index == 0 && state.dateTimeRange != null) ||
              (index == 1 &&
                  state.categoryFilters != null &&
                  state.categoryFilters!.isNotEmpty) ||
              (index == 2 && state.selectedbank != null);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              // Highlight color if active
              color: isFilterActive
                  ? AppColors.secondaryColor.withOpacity(0.1)
                  : AppColors.filterFillColor,
              border: Border.all(
                color: isFilterActive
                    ? AppColors.secondaryColor
                    : AppColors.filterBorderColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (index == 0) _pickDateRange(context, index);
                    if (index == 1) _showFilterCategoryDialog(context, index);
                    if (index == 2) _showBankFilterDialog(context, index);
                  },
                  child: Text(
                    labels[index],
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: isFilterActive
                          ? AppColors.secondaryColor
                          : AppColors.filterTextColor,
                      fontWeight: isFilterActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: isFilterActive
                      ? () {
                          print('Date');
                          if (index == 0) {
                            context.read<ActivityBloc>().add(
                              SetDateFilterEvent(index: index, timeRange: null),
                            );
                          }
                          if (index == 1) {
                            context.read<ActivityBloc>().add(
                              SetDateFilterEvent(
                                index: index,
                                selectedCategory: null,
                              ),
                            );
                          }

                          if (index == 2) {
                            context.read<ActivityBloc>().add(
                              SetDateFilterEvent(
                                index: index,
                                selectedBank: null,
                                selectedbankIndex: null,
                              ),
                            );
                          }
                        }
                      : null,
                  child: SvgPicture.asset(
                    isFilterActive
                        ? AppIcons.cancelIcon
                        : AppIcons.dropDownArrowIcon,
                    height: 16,
                    width: 16,
                    colorFilter: ColorFilter.mode(
                      isFilterActive
                          ? AppColors.secondaryColor
                          : AppColors.filterTextColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget _buildTransactionList(BuildContext context, ActivityState state) {
  //   return RefreshIndicator(
  //     onRefresh: () async => context.read<ActivityBloc>().add(LoadTransactions()),
  //     color: AppColors.secondaryColor,
  //     backgroundColor: AppColors.primaryColor,
  //     child: CustomScrollView(
  //       physics: const AlwaysScrollableScrollPhysics(
  //         parent: BouncingScrollPhysics(),
  //       ),
  //       slivers: [
  //         if (state.transactions.isEmpty)
  //           SliverFillRemaining(
  //             hasScrollBody: false,
  //             child: Center(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.filter_list_off_rounded,
  //                       size: 64, color: AppColors.greyishColor),
  //                   const SizedBox(height: 16),
  //                   Text(
  //                     "No transactions\nfound.",
  //                     textAlign: TextAlign.center,
  //                     style: Theme.of(context).textTheme.displaySmall!.copyWith(
  //                           color: AppColors.greyAccentColor,
  //                           fontSize: 25,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         SliverList.builder(
  //           itemCount: state.transactions.length,
  //           itemBuilder: (context, index) {
  //             final txn = state.transactions[index];
  //             final icon = state.categoryIcons[txn.categoryName] ??
  //                 Icons.category_rounded;
  //             return TransactionTile(
  //               transaction: txn,
  //               categoryIcon: icon,
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTransactionList(BuildContext context, ActivityState state) {
    // 1. Prepare the Data (ALWAYS Group by Day)
    final List<dynamic> listItems = [];

    if (state.transactions.isNotEmpty) {
      String? lastDateLabel;

      for (var txn in state.transactions) {
        // Calculate the header (e.g., "Today" or "Jan 15")
        final String dateLabel = _getRelativeDate(txn.date);

        // If the day changed, insert a new Header
        if (dateLabel != lastDateLabel) {
          listItems.add(dateLabel); // Add Header String
          lastDateLabel = dateLabel;
        }

        // Add the Transaction itself
        listItems.add(txn);
      }
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<ActivityBloc>().add(LoadTransactions()),
      color: AppColors.secondaryColor,
      backgroundColor: AppColors.primaryColor,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // EMPTY STATE
          if (state.transactions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.filter_list_off_rounded,
                      size: 64,
                      color: AppColors.greyishColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No transactions\nfound.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: AppColors.greyAccentColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // LIST CONTENT
          SliverList.builder(
            itemCount: listItems.length,
            itemBuilder: (context, index) {
              final item = listItems[index];

              // A. HEADER (String)
              if (item is String) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: Dimensions.horizontal(context),
                    right: Dimensions.horizontal(context),
                    top: 6, // More space above new sections
                    bottom: 4,
                  ),
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppColors.greyTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              // B. TRANSACTION (Model)
              if (item is TransactionModel) {
                final icon =
                    state.categoryIcons[item.categoryName] ??
                    Icons.category_rounded;

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    TransactionDetailsPage.routeName,
                    arguments: {
                      'transaction': item,

                      // Pass Data
                      'categoryNames': state.myCategories,
                      'categoryIcons': state.categoryIcons,

                      // Pass Functions
                      'onCategoryChanged':
                          (TransactionModel transaction, String newCategory) {
                            context.read<ActivityBloc>().add(
                              ChangeCategoryEvent(transaction, newCategory),
                            );
                          },
                      'onCategoryAdded': (String name, String iconData) {
                        context.read<ActivityBloc>().add(
                          AddNewCategoryEvent(name: name, iconJson: iconData),
                        );
                      },
                    },
                  ),
                  child: TransactionTile(transaction: item, categoryIcon: icon),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  // --- HELPER: Formats the Date Header ---
  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return "Today";
    } else if (itemDate == yesterday) {
      return "Yesterday";
    } else {
      // If same year: "Tue, Jan 15"
      // If diff year: "Jan 15, 2024"
      if (date.year == now.year) {
        return DateFormat('EEE, MMM d').format(date);
      } else {
        return DateFormat('MMM d, y').format(date);
      }
    }
  }

  Future<void> _pickDateRange(BuildContext context, int index) async {
    final state = context.read<ActivityBloc>().state;
    // Open the Date Range Picker
    final DateTimeRange? result = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) =>
          CustomDateRangePicker(initialDateRange: state.dateTimeRange),
    );
    if (result != null) {
      // ✅ Trigger the Bloc Event
      if (context.mounted) {
        context.read<ActivityBloc>().add(
          SetDateFilterEvent(index: index, timeRange: result),
        );
      }
    }
  }

  String _formatSmartRange(DateTime start, DateTime end) {
    final monthFormat = DateFormat('MMMM'); // "January"
    final dayFormat = DateFormat('d'); // "13"

    if (start.month == end.month && start.year == end.year) {
      // Same Month: "January 13 - 15"
      return '${monthFormat.format(start)} ${dayFormat.format(start)} - ${dayFormat.format(end)}';
    } else {
      // Different Months: "January 30 - February 2"
      final fullFormat = DateFormat('MMMM d');
      return '${fullFormat.format(start)} - ${fullFormat.format(end)}';
    }
  }
}
