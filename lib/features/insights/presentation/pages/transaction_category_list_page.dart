import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/home/presentation/pages/transaction_details_page.dart';
import 'package:naira_sms_pulse/features/home/presentation/widgets/transaction_tile.dart';
import 'package:naira_sms_pulse/features/insights/presentation/bloc/insight_bloc.dart';
import 'package:naira_sms_pulse/features/insights/presentation/bloc/insight_state.dart';
// import 'package:naira_sms_pulse/features/transactions/presentation/pages/transaction_detail_page.dart'; // Import your detail page

class CategoryTransactionsPage extends StatelessWidget {
  static const String routeName = 'transaction_category_list_page';

  final String categoryName;

  const CategoryTransactionsPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Sort by date (newest first)
    // final sortedTxns = List<TransactionModel>.from(transactions)
    //   ..sort((a, b) => b.date.compareTo(a.date));

    return BlocConsumer<InsightBloc, InsightState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        // 1. Live Filter: Get latest transactions for this category
        final categoryTransactions = state.transactions
            .where((txn) => (txn.categoryName) == categoryName)
            .toList();

        // 2. Sort (Newest first)
        categoryTransactions.sort((a, b) => b.date.compareTo(a.date));

        // 3. Handle Empty State (If you moved the last item out)
        if (categoryTransactions.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                categoryName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            body: Center(child: Text("No transactions left in $categoryName")),
          );
        }

        //
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              categoryName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black, // Back button color
          ),
          body: ListView.separated(
            //padding: const EdgeInsets.all(16),
            //   itemCount: sortedTxns.length,
            itemCount: categoryTransactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final txn = categoryTransactions[index];
              return _buildTransactionTile(context, txn, state);
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    TransactionModel txn,
    InsightState state,
  ) {
    return GestureDetector(
      onTap: () {
        print(state.categoryIcons);
        print(state.categoryNames);
        print(state.categorySummary);
        // NAVIGATE TO TRANSACTION DETAILS
        Navigator.pushNamed(
          context,
          TransactionDetailsPage.routeName,
          arguments: {
            'transaction': txn,

            // Pass Data
            'categoryNames': state.categoryNames,
            'categoryIcons': state.categoryIcons,

            // Pass Functions
            'onCategoryChanged':
                (TransactionModel transaction, String newCategory) {
                  context.read<InsightBloc>().add(
                    ChangeCategoryEvent(transaction, newCategory),
                  );
                },
            'onCategoryAdded': (String name, String iconData) {
              context.read<InsightBloc>().add(
                AddNewCategoryEvent(name: name, iconJson: iconData),
              );
            },

            'onPartyChanged': (TransactionModel transaction, String newName) {
              context.read<InsightBloc>().add(
                UpdateTransactionPartyEvent(
                  transaction: transaction,
                  name: newName,
                ),
              );
            },
          },
        );
        // OR
        // Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailPage(transaction: txn)));
      },
      child: TransactionTile(
        transaction: txn,
        categoryIcon:
            state.categoryIcons[txn.categoryName] ?? Icons.category_rounded,
      ),
      // child: Container(
      //   padding: const EdgeInsets.all(16),
      //   decoration: BoxDecoration(
      //     // color: AppColors.thinTwoGreyColor,
      //     borderRadius: BorderRadius.circular(16),
      //     border: Border.all(color: AppColors.thinTwoGreyColor),
      //   ),
      //   child: Row(
      //     children: [
      //       // Date Box
      //       Container(
      //         padding: const EdgeInsets.all(10),
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.circular(12),
      //         ),
      //         child: Column(
      //           children: [
      //             Text(
      //               DateFormat('MMM').format(txn.date), // "Jan"
      //               style: TextStyle(
      //                 fontSize: 10,
      //                 fontWeight: FontWeight.bold,
      //                 color: AppColors.greyTextColor,
      //               ),
      //             ),
      //             Text(
      //               DateFormat('d').format(txn.date), // "12"
      //               style: const TextStyle(
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       const SizedBox(width: 16),

      //       // Details
      //       Expanded(
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //               txn.transactionParty,
      //               maxLines: 1,
      //               overflow: TextOverflow.ellipsis,
      //               style: const TextStyle(
      //                 fontWeight: FontWeight.bold,
      //                 fontSize: 16,
      //               ),
      //             ),
      //             const SizedBox(height: 4),
      //             Text(
      //               DateFormat('h:mm a').format(txn.date), // "2:30 PM"
      //               style: TextStyle(
      //                 fontSize: 12,
      //                 color: AppColors.greyTextColor,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),

      //       // Amount
      //       Text(
      //         '-₦${NumberFormat.currency(symbol: '', decimalDigits: 0).format(txn.amount)}',
      //         style: Theme.of(context).textTheme.headlineSmall!.copyWith(
      //           color: AppColors.filterTextColor,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
