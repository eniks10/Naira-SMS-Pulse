import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_state.dart';

class BankSelectorWidget extends StatelessWidget {
  const BankSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Determine what text to show on the pod
        String label = "All Accounts";
        if (state.selectedBankIndex > 0 && state.availableBanks.isNotEmpty) {
          // index - 1 because index 0 is "All"
          label = state.availableBanks[state.selectedBankIndex - 1].bankName;
        }

        return GestureDetector(
          onTap: () => _showBankSelectionDialog(context, state),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 16,
                  color: AppColors.secondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBankSelectionDialog(BuildContext context, HomeState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Account",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),

              // Option 0: All Accounts
              ListTile(
                leading: const Icon(Icons.apps_rounded),
                title: const Text("All Accounts"),
                trailing: state.selectedBankIndex == 0
                    ? Icon(Icons.check_circle, color: AppColors.secondaryColor)
                    : null,
                onTap: () {
                  context.read<HomeBloc>().add(BankChangedEvent(index: 0));
                  Navigator.pop(context);
                },
              ),

              // Dynamic Options: Available Banks
              ...List.generate(state.availableBanks.length, (index) {
                final bank = state.availableBanks[index];
                // The bloc index is list_index + 1
                final isSelected = state.selectedBankIndex == (index + 1);

                return ListTile(
                  leading: const Icon(Icons.account_balance_rounded),
                  title: Text(bank.bankName),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.secondaryColor,
                        )
                      : null,
                  onTap: () {
                    context.read<HomeBloc>().add(
                      BankChangedEvent(index: index + 1),
                    );
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
