import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:naira_sms_pulse/core/config/asset/app_icons.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_state.dart';

class PulseCard extends StatelessWidget {
  final double totalSpent;
  final double totalIncome;

  // 1. 👇 ADD THESE NEW VARIABLES
  final String title;
  final HomeState state;
  final VoidCallback onTap;

  const PulseCard({
    super.key,
    required this.totalSpent,
    required this.totalIncome,
    // 2. 👇 UPDATE CONSTRUCTOR (Default title keeps old behavior safe)
    required this.title,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final screenWidth = Dimensions.screenWidth(context);

    return Container(
      width: double.infinity,
      //padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Bank Selector
          _buildBankSwitcher(context, screenWidth),
          // Label
          SizedBox(height: 15),
          Text(
            'Total Weekly Expense', // 👈 4. USE THE DYNAMIC TITLE
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.lightGreyTextColor,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),

          // Big Expense Number
          Text(
            currency.format(totalSpent),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
              fontSize: 40,
            ),
          ),

          const SizedBox(height: 5),

          // Income Row
          RichText(
            text: TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: AppColors.creditColor),
              children: [
                TextSpan(text: currency.format(totalIncome)),

                TextSpan(
                  text: ' Monthly Income',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightGreyTextColor,
                    letterSpacing: 0,
                    // fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSwitcher(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: onTap, // Ensure 'onTap' is defined in your class or passed in
      child: Container(
        // 1. CONSTRAINT: Prevents it from getting too wide on big screens,
        // but allows it to be small if the text is short.
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.5, // limit to 50% of screen
          minWidth: 120, // minimum size so it's easy to tap
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.thinGreyColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          // 2. TIGHT LAYOUT: This keeps elements close to each other
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- BANK IMAGE ---
            Container(
              height: 24, // Fixed size
              width: 24, // Fixed size
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                // Optional: Add a white bg to make the logo pop against the grey pill
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: _buildBankHolder(),
            ),

            const SizedBox(width: 8), // Gap between icon and text
            // --- BANK NAME ---
            Flexible(
              fit: FlexFit.loose, // Let the text shrink if needed
              child: Text(
                title, // Ensure 'title' is calculated correctly based on index
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Slightly smaller for the pill look
                ),
              ),
            ),

            const SizedBox(width: 8), // Gap between text and arrow
            // --- DROPDOWN ARROW ---
            SvgPicture.asset(
              AppIcons.dropDownArrowIcon,
              height: 12, // Slightly smaller to be subtle
              width: 12,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                AppColors.secondaryColor,
                BlendMode.srcIn,
              ),
            ),

            // Add a tiny bit of padding at the end for visual balance
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGET ---
  Widget _buildBankHolder() {
    // Logic: 0 is All, anything else is a bank
    if (state.selectedBankIndex == 0) {
      return Icon(
        Icons.account_balance,
        size: 16,
        color: AppColors.secondaryColor, // Make it pop
      );
    }

    // Get the bank safely
    // Note: Ensure your index logic matches your list (index - 1)
    final bank = state.selectedbanks[state.selectedBankIndex - 1];

    if (bank.logoUrl == null) {
      return Icon(
        Icons.account_balance,
        size: 16,
        color: AppColors.greyTextColor,
      );
    }

    return ClipOval(
      child: SvgPicture.network(
        bank.logoUrl!,
        height: 24, // Match parent container
        width: 24, // Match parent container
        fit: BoxFit.cover,
        placeholderBuilder: (_) => Icon(
          Icons.account_balance,
          size: 16,
          color: AppColors.greyTextColor,
        ),
      ),
    );
  }
}
