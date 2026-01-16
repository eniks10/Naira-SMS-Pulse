import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_state.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final IconData categoryIcon;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.transactionType == TransactionType.credit;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFmt = DateFormat('MMM d, h:mm a');
    final opacity = transaction.excludeFromAnalytics ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => _buildOptionsSheet(context),
          );
        },
        child: Container(
          // margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.horizontal(context),
          ).copyWith(bottom: Dimensions.large),
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(16),
          //   border: Border.all(color: Colors.grey.shade100),
          // ),
          child: Row(
            children: [
              // 1. Category Icon
              Container(
                padding: EdgeInsets.all(5),
                // height: 48,
                // width: 48,
                decoration: BoxDecoration(
                  // color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                  //borderRadius: BorderRadius.circular(12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.thinGreyColor),
                ),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCredit
                        ? AppColors.successColor.withValues(alpha: 0.12)
                        : AppColors.errorColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    categoryIcon, // Replace with dynamic Category Icon later
                    color: isCredit ? Colors.green : Colors.redAccent,
                    size: 21,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 2. Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // transaction.description.isEmpty
                      //     ? transaction.transactionParty
                      //     : transaction.description,
                      transaction.isAiEnriched
                          ? transaction.transactionParty
                          : 'Unresolved',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: transaction.isAiEnriched
                            ? AppColors.secondaryColor
                            : AppColors.orangeTextColor,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFmt.format(transaction.date),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.greyAccentColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Amount
              Text(
                //"${isCredit ? '+' : '-'}${currency.format(transaction.amount)}",
                currency.format(transaction.amount),
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: isCredit
                      ? AppColors.successColor
                      : AppColors.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildOptionsSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              transaction.excludeFromAnalytics
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            title: Text(
              transaction.excludeFromAnalytics
                  ? "Include in Analytics"
                  : "Exclude from Analytics",
            ),
            subtitle: Text("This won't affect your total balance."),
            onTap: () {
              Navigator.pop(context);
              context.read<HomeBloc>().add(
                ToggleTransactionVisibilityEvent(transaction: transaction),
              );
            },
          ),
        ],
      ),
    );
  }
}
