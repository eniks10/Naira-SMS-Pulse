import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/core/helpers/sms_permission.dart';
import 'package:naira_sms_pulse/features/auth/presentation/widgets/loading_overlay.dart';
import 'package:naira_sms_pulse/features/main_layout/presentation/pages/main_layout_page.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/pages/message_permission_page.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/pages/select_bank_page.dart';

class OnboardingPage extends StatefulWidget {
  static const String routeName = 'onboarding_page';
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  List<BankModel> availableBankList = [];

  @override
  void initState() {
    super.initState();
    context.read<OnboardingCubit>().loadBanks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.pageIndex == 1) {
            _pageController.animateToPage(
              state.pageIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuart,
            );
          }

          if (state.initialPermission) {
            SmsPermissionHelper.requestPermission(context);
          }

          if (state.transactions.isNotEmpty) {
            Navigator.pushReplacementNamed(context, MainLayoutPage.routeName);
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            widget: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                //----Page 1----
                SelectBankPage(bankList: state.availableBanks),
                //-----Page 2----
                MessagePermissionPage(),
              ],
            ),
            isLoading: state.isLoading,
          );
        },
      ),
    );
  }
}
