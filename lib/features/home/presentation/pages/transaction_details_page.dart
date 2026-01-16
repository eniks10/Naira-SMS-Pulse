import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/core/config/asset/app_icons.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/alerts.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_state.dart';
import 'package:naira_sms_pulse/features/home/presentation/pages/add_category_dialog.dart';

class TransactionDetailsPage extends StatefulWidget {
  static const routeName = 'transaction_details_page';

  final TransactionModel transaction;
  final HomeState state;

  const TransactionDetailsPage({
    super.key,
    required this.transaction,
    required this.state,
  });

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // 2. FIND THE LATEST VERSION OF THIS TRANSACTION
        // We look inside the Bloc's list for the transaction with the same ID.
        // If we can't find it (rare), we fall back to the widget.transaction.
        final liveTransaction = state.transactions.firstWhere(
          (t) => t.id == widget.transaction.id,
          orElse: () => widget.transaction,
        );

        final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
        final dateFmt = DateFormat('MMM d, yyyy • h:mm a');

        // Determine colors based on type
        final isCredit =
            liveTransaction.transactionType == TransactionType.credit;
        final amountColor = isCredit
            ? AppColors.successColor
            : AppColors.secondaryColor;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.horizontal(context),
              ).copyWith(bottom: Dimensions.bottom(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        //back Sign and ignore
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.arrow_back_ios),
                              color: AppColors.secondaryColor,
                              constraints: BoxConstraints(
                                minWidth: 21,
                                minHeight: 21,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: liveTransaction.excludeFromAnalytics
                                  ? Icon(
                                      Icons.visibility_off_outlined,
                                      size: 24,
                                    )
                                  : Icon(Icons.visibility_outlined, size: 24),
                              color: AppColors.secondaryColor,

                              constraints: BoxConstraints(
                                minWidth: 21,
                                minHeight: 21,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // 2. HERO AMOUNT
                        Text(
                          currency.format(liveTransaction.amount),
                          style: Theme.of(context).textTheme.displayMedium!
                              .copyWith(color: amountColor),
                        ),
                        const SizedBox(height: 40),

                        //Upper Container(Name and category)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.thinTwoGreyColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          // height: 48,
                                          // width: 48,
                                          decoration: BoxDecoration(
                                            // color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                                            //borderRadius: BorderRadius.circular(12),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.thinGreyColor,
                                            ),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isCredit
                                                  ? AppColors.successColor
                                                        .withValues(alpha: 0.12)
                                                  : AppColors.errorColor
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                            ),
                                            child: Icon(
                                              state.categoryIcons[widget
                                                  .transaction
                                                  .categoryName],
                                              // isCredit
                                              //     ? Icons.credit_card
                                              //     : Icons
                                              //           .shopping_bag_outlined, // Replace with dynamic Category Icon later
                                              color: isCredit
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                liveTransaction.isAiEnriched
                                                    ? liveTransaction
                                                          .transactionParty
                                                    : 'Unresolved',
                                                // liveTransaction.transactionParty,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      color:
                                                          widget
                                                              .transaction
                                                              .isAiEnriched
                                                          ? AppColors
                                                                .secondaryColor
                                                          : AppColors
                                                                .orangeTextColor,
                                                      letterSpacing: 0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                liveTransaction.isAiEnriched
                                                    ? liveTransaction
                                                          .categoryName
                                                    : 'Unresolved',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color:
                                                          widget
                                                              .transaction
                                                              .isAiEnriched
                                                          ? AppColors
                                                                .greyAccentColor
                                                          : AppColors
                                                                .orangeTextColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColors.greyAccentColor,
                                    size: 15,
                                  ),
                                ],
                              ),

                              //Button
                              SizedBox(height: Dimensions.medium),
                              SizedBox(
                                width: double.infinity,
                                height: Dimensions.smallbuttonHeight,

                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.greyButtonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(16),
                                    ),
                                  ),
                                  onPressed: () {
                                    showChangeCategoryDialog(
                                      context,
                                      state,
                                      liveTransaction,
                                    );
                                  },
                                  child: Text(
                                    'Edit Category',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: AppColors.greyAccentColor,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10),

                        // 3. DETAILS CARD
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.thinTwoGreyColor,
                            borderRadius: BorderRadius.circular(20),
                            // border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                "Date",
                                dateFmt.format(liveTransaction.date),
                              ),
                              const Divider(),
                              _buildDetailRow(
                                "Description",
                                liveTransaction.description,
                              ),
                              const Divider(),
                              _buildDetailRow(
                                "Account",
                                liveTransaction.bankName.toUpperCase(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // // 4. SETTINGS & ACTIONS
                        // _buildActionTile(
                        //   icon: Icons.category_rounded,
                        //   title: "Category",
                        //   value:liveTransaction.categoryName,
                        //   onTap: () => _showCategoryPicker(context),
                        // ),

                        // const SizedBox(height: 10),

                        // // IGNORE SWITCH
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(16),
                        //     border: Border.all(color: Colors.grey.shade200),
                        //   ),
                        //   child: SwitchListTile(
                        //     value: !widget
                        //         .transaction
                        //         .excludeFromAnalytics, // ON = Included
                        //     activeColor: AppColors.secondaryColor,
                        //     title: const Text("Include in Analytics"),
                        //     subtitle: const Text(
                        //       "Turn off to hide this from your total balance.",
                        //     ),
                        //     onChanged: (val) {
                        //       setState(() {
                        //         // liveTransaction =liveTransaction.copyWith(excludeFromAnalytics: !val);
                        //       });
                        //       // Trigger Bloc
                        //       context.read<HomeBloc>().add(
                        //         ToggleTransactionVisibilityEvent(
                        //           transaction:liveTransaction,
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                        const SizedBox(height: 10),

                        // SPLIT BUTTON
                      ],
                    ),
                  ),
                  // SPLIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: Dimensions.smallbuttonHeight,
                    child: OutlinedButton(
                      onPressed: () {
                        // Show Split Dialog (Logic below)
                        // _showSplitDialog(context);
                        // _openAddCategoryDialog(context);
                      },

                      style: OutlinedButton.styleFrom(
                        // minimumSize: const Size(double.infinity, 50),
                        side: BorderSide(color: AppColors.secondaryColor),
                        // foregroundColor: AppColors.secondaryColor,
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: Text(
                        'Split Transaction',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // void _showAddCategorySheet(BuildContext context) {
  //   final state = context.read<HomeBloc>().state;

  //   // 2. Extract Names and Icons
  //   final usedNames = state.categoryNames;
  //   final usedIcons = state.categoryIcons.values.toList();
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // Allows the sheet to be full height
  //     backgroundColor:
  //         Colors.transparent, // Transparent back for custom rounding
  //     builder: (context) => Padding(
  //       // This padding makes the sheet push up when the keyboard opens
  //       padding: EdgeInsets.only(
  //         bottom: MediaQuery.of(context).viewInsets.bottom,
  //       ),
  //       child: AddCategoryBottomSheet(
  //         existingCategories: usedNames,
  //         usedIcons: usedIcons,
  //       ),
  //     ),
  //   );
  // }
  // Make the function async so we can 'await' the result
  void _showAddCategorySheet() async {
    final state = context.read<HomeBloc>().state;
    final usedNames = state.categoryNames;
    final usedIcons = state.categoryIcons.values.toList();

    print("DEBUG: Opening Bottom Sheet...");

    // 1. Await the result from the bottom sheet
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategoryBottomSheet(
        existingCategories: usedNames,
        usedIcons: usedIcons,
      ),
    );
    print("DEBUG: Bottom Sheet Closed. Result: $result"); // Debug 2
    // 2. Check if data came back (User didn't just close the sheet)

    if (result != null && result is Map) {
      final name = result['name']!;
      final iconJson = result['iconData']!;

      print("DEBUG: Data received - Name: $name"); // Debug 3
      // 3. Send to Bloc
      if (context.mounted) {
        print("DEBUG: Context is mounted! Firing Bloc Event...");
        // 1. CREATE IT (So it exists for future use)
        context.read<HomeBloc>().add(
          AddNewCategoryEvent(name: name, iconJson: iconJson),
        );

        // 2. APPLY IT (Update THIS transaction immediately) 👈 ADD THIS!
        context.read<HomeBloc>().add(
          ChangeCategoryEvent(widget.transaction, name),
        );
        AppAlerts.shoeSuccess(
          context: context,
          message: "Category '$name' created successfully!",
        );
      }
    } else {
      print("DEBUG: Result was null or wrong type");
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.greyAccentColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryColor),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 📝 CATEGORY PICKER

  // ✂️ SPLIT DIALOG (Coming Soon Logic)
  void _showSplitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Split Transaction"),
        content: const Text(
          "This feature will allow you to break this transaction into multiple categories (e.g., Food & Transport).\n\nComing in the next update!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  // void showFloatingBottomDialog(
  //   BuildContext context,
  //   HomeState state,
  //   TransactionModel transaction,
  // ) {
  //   final screenHeight = MediaQuery.of(context).size.height;

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Align(
  //         alignment: Alignment.bottomCenter,
  //         child: Container(
  //           // 1. CONSTRAINTS: Max 50% screen height, Min 0 (shrink wrap)
  //           constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
  //           margin: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
  //           decoration: BoxDecoration(
  //             color: AppColors.primaryColor,
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: Material(
  //             color: Colors.transparent,
  //             child: Padding(
  //               padding: EdgeInsets.all(Dimensions.horizontal(context)),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min, // Shrinks to fit content
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // --- HEADER ---
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         "Select a Category",
  //                         style: Theme.of(context).textTheme.bodyLarge!
  //                             .copyWith(color: AppColors.secondaryColor),
  //                       ),
  //                       GestureDetector(
  //                         onTap: () => Navigator.pop(context),
  //                         child: Container(
  //                           decoration: BoxDecoration(
  //                             shape: BoxShape.circle,
  //                             color: AppColors.thinGreyColor,
  //                           ),
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: SvgPicture.asset(
  //                             AppIcons.cancelIcon,
  //                             height: 20,
  //                             width: 20,
  //                             fit: BoxFit.cover,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),

  //                   const SizedBox(height: 5),
  //                   Divider(color: AppColors.greyishColor),
  //                   const SizedBox(height: 10),

  //                   // --- SCROLLABLE CONTENT ---
  //                   // Flexible allows the child to shrink, but scroll if too big
  //                   Flexible(
  //                     child: SingleChildScrollView(
  //                       child: Wrap(
  //                         spacing: 12, // Gap between items horizontally
  //                         runSpacing: 12, // Gap between lines vertically
  //                         children: state.categoryNames.map((category) {
  //                           final isSelected =
  //                               category == transaction.categoryName;

  //                           return GestureDetector(
  //                             onTap: () {
  //                               // Handle tap
  //                               context.read<HomeBloc>().add(
  //                                 ChangeCategoryEvent(transaction, category),
  //                               );
  //                               Navigator.pop(context);
  //                             },
  //                             child: Container(
  //                               // Padding makes the pill size dynamic based on text
  //                               padding: const EdgeInsets.symmetric(
  //                                 horizontal: 16,
  //                                 vertical: 10,
  //                               ),
  //                               decoration: BoxDecoration(
  //                                 color: isSelected
  //                                     ? AppColors.secondaryColor.withOpacity(
  //                                         0.1,
  //                                       )
  //                                     : AppColors.whitishGreyTextColor,
  //                                 border: Border.all(
  //                                   color: isSelected
  //                                       ? AppColors.secondaryColor
  //                                       : AppColors.thinGreyColor,
  //                                   width: 1.5,
  //                                 ),
  //                                 borderRadius: BorderRadius.circular(
  //                                   20,
  //                                 ), // Pill shape
  //                               ),
  //                               child: Text(
  //                                 category,
  //                                 style: Theme.of(context).textTheme.bodyMedium!
  //                                     .copyWith(
  //                                       color: isSelected
  //                                           ? AppColors.secondaryColor
  //                                           : AppColors.secondaryColor
  //                                                 .withOpacity(0.8),
  //                                       fontWeight: isSelected
  //                                           ? FontWeight.bold
  //                                           : FontWeight.normal,
  //                                     ),
  //                               ),
  //                             ),
  //                           );
  //                         }).toList(),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  void showChangeCategoryDialog(
    BuildContext context,
    HomeState state,
    TransactionModel transaction,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    final isDebit = transaction.transactionType == TransactionType.debit;

    // 1. DEFINE THE LISTS
    const incomeCategories = ['Taxable Income', 'Non-Taxable Income'];

    // 2. FILTER BASED ON TYPE
    List<String> categoriesToShow;

    if (isDebit) {
      // Show all DB categories EXCEPT the income ones
      categoriesToShow = state.categoryNames
          .where((cat) => !incomeCategories.contains(cat))
          .toList();
    } else {
      // Show ONLY the two income options
      categoriesToShow = incomeCategories;
    }

    showDialog(
      context: context,
      builder: (context) {
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
                          isDebit ? "Select a Category" : "Classify Income",

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
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: state.categoryNames.map((category) {
                            final isSelected =
                                category == transaction.categoryName;

                            return GestureDetector(
                              onTap: () {
                                context.read<HomeBloc>().add(
                                  ChangeCategoryEvent(transaction, category),
                                );
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.secondaryColor.withOpacity(
                                          0.1,
                                        )
                                      : AppColors.whitishGreyTextColor,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.secondaryColor
                                        : AppColors.thinGreyColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: Theme.of(context).textTheme.bodyMedium!
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
                      ),
                    ),

                    if (isDebit) ...[
                      const SizedBox(height: 20), // Spacing before button
                      // --- 3. ADD CATEGORY BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        height: Dimensions.smallbuttonHeight,
                        child: OutlinedButton(
                          onPressed: () {
                            // Close this selection dialog first
                            Navigator.pop(context);

                            // Then open the "Add New" dialog
                            _showAddCategorySheet();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.secondaryColor),
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Add Category', // Changed text
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: AppColors.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
