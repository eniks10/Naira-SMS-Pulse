

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/core/config/asset/app_icons.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/home/presentation/pages/add_category_dialog.dart';

class TransactionDetailsPage extends StatefulWidget {
  static const routeName = 'transaction_details_page';

  final TransactionModel transaction;

  // 1. DATA DEPENDENCIES (Passed from Parent)
  final List<String> categoryNames;
  final Map<String, IconData> categoryIcons;

  // 2. ACTION CALLBACKS (What happens when we edit?)
  final Function(TransactionModel txn, String newCategory) onCategoryChanged;
  final Function(String name, String iconData) onCategoryAdded;
  final Function(TransactionModel txn, String newName) onPartyChanged;

  const TransactionDetailsPage({
    super.key,
    required this.transaction,
    required this.categoryNames,
    required this.categoryIcons,
    required this.onCategoryChanged,
    required this.onCategoryAdded,
    required this.onPartyChanged,
  });

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  // We keep a local copy to update the UI instantly when user edits
  late TransactionModel liveTransaction;

  @override
  void initState() {
    super.initState();
    liveTransaction = widget.transaction;
  }

  @override
  Widget build(BuildContext context) {
    // Formatting
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFmt = DateFormat('MMM d, yyyy • h:mm a');
    final isCredit = liveTransaction.transactionType == TransactionType.credit;
    final amountColor = isCredit
        ? AppColors.successColor
        : AppColors.secondaryColor;

    // Get Icon (Safe fallback)
    final categoryIcon =
        widget.categoryIcons[liveTransaction.categoryName] ?? Icons.category;

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
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios),
                          color: AppColors.secondaryColor,
                          constraints: const BoxConstraints(
                            minWidth: 21,
                            minHeight: 21,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            liveTransaction.excludeFromAnalytics
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 24,
                          ),
                          color: AppColors.secondaryColor,
                          constraints: const BoxConstraints(
                            minWidth: 21,
                            minHeight: 21,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // --- HERO AMOUNT ---
                    Text(
                      currency.format(liveTransaction.amount),
                      style: Theme.of(context).textTheme.displayMedium!
                          .copyWith(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -2,
                          ),
                    ),
                    const SizedBox(height: 40),

                    // --- MAIN CARD (Name & Category) ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.thinTwoGreyColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.thinGreyColor,
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCredit
                                              ? AppColors.successColor
                                                    .withOpacity(0.12)
                                              : AppColors.errorColor
                                                    .withOpacity(0.12),
                                        ),
                                        child: Icon(
                                          categoryIcon,
                                          color: isCredit
                                              ? Colors.green
                                              : Colors.redAccent,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
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
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  color:
                                                      liveTransaction
                                                          .isAiEnriched
                                                      ? AppColors.secondaryColor
                                                      : AppColors
                                                            .orangeTextColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            liveTransaction.categoryName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color:
                                                      AppColors.greyAccentColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  _showEditPartyNameSheet();
                                },
                                icon: Icon(Icons.edit, size: 20),
                                color: AppColors.greyAccentColor,
                              ),
                            ],
                          ),
                          SizedBox(height: Dimensions.medium),

                          // --- EDIT BUTTON ---
                          SizedBox(
                            width: double.infinity,
                            height: Dimensions.smallbuttonHeight,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.greyButtonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () =>
                                  showChangeCategoryDialog(context),
                              child: Text(
                                'Edit Category',
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(color: AppColors.greyAccentColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- DETAILS CARD ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.thinTwoGreyColor,
                        borderRadius: BorderRadius.circular(20),
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
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER METHODS ---

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
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategorySheet() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategoryBottomSheet(
        existingCategories: widget.categoryNames,
        usedIcons: widget.categoryIcons.values.toList(),
      ),
    );

    if (result != null && result is Map) {
      final name = result['name']!;
      final iconJson = result['iconData']!;

      // 1. Call the callback to update the Parent Bloc
      widget.onCategoryAdded(name, iconJson);

      // 2. Update THIS page immediately
      _updateCategoryLocally(name);
    }
  }

  void showChangeCategoryDialog(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDebit = liveTransaction.transactionType == TransactionType.debit;
    const incomeCategories = ['Taxable Income', 'Non-Taxable Income'];

    // Filter Logic
    List<String> categoriesToShow = [];
    if (isDebit) {
      categoriesToShow = widget.categoryNames
          .where((cat) => !incomeCategories.contains(cat))
          .toList();
    } else {
      categoriesToShow = incomeCategories;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
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
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: AppColors.greyishColor),
                    const SizedBox(height: 10),

                    // List
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: categoriesToShow.map((category) {
                            final isSelected =
                                category == liveTransaction.categoryName;

                            return GestureDetector(
                              onTap: () {
                                _updateCategoryLocally(category);
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: Dimensions.smallbuttonHeight,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
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
                            'Add Category',
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

  // --- LOGIC: HANDLE UPDATES ---
  void _updateCategoryLocally(String newCategory) {
    // 1. Update the Parent (Bloc)
    widget.onCategoryChanged(liveTransaction, newCategory);

    // 2. Update the UI locally instantly
    setState(() {
      liveTransaction = liveTransaction.copyWith(categoryName: newCategory);
    });
  }

  // --- LOGIC: EDIT PARTY NAME ---
  void _showEditPartyNameSheet() {
    final TextEditingController controller = TextEditingController(
      text: liveTransaction.transactionParty,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          // 1. Move the keyboard padding wrapper OUTSIDE the container
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            // 2. THE FIX: Wrap content in SingleChildScrollView
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20), // Move inner padding here
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Edit Transaction Name",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryColor,
                              ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Text Field
                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        //  labelText: "Merchant / Party Name",
                        labelStyle: TextStyle(color: AppColors.greyAccentColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.thinGreyColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.secondaryColor,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.thinTwoGreyColor,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save Button
                    // inside _showEditPartyNameSheet builder...
                    SizedBox(
                      width: double.infinity,
                      height: Dimensions.smallbuttonHeight,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          // 1. Make this ASYNC
                          final newName = controller.text.trim();

                          if (newName.isNotEmpty) {
                            // 2. Kill the keyboard immediately
                            FocusScope.of(context).unfocus();

                            // 3. WAIT for the keyboard to slide down (The Magic Fix)
                            // This gives the layout time to reset before popping the sheet
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );

                            if (context.mounted) {
                              _updatePartyNameLocally(newName);
                              Navigator.pop(
                                context,
                              ); // 4. Now close the sheet safely
                            }
                          }
                        },
                        child: const Text("Save Changes"),
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
  }

  void _updatePartyNameLocally(String newName) {
    // 1. Update the Parent (Bloc / Database)
    widget.onPartyChanged(liveTransaction, newName);

    // 2. Update the UI locally instantly
    setState(() {
      liveTransaction = liveTransaction.copyWith(transactionParty: newName);
    });
  }
}
