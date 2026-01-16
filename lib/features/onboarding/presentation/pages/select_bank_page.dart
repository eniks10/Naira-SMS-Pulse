import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:naira_sms_pulse/core/config/asset/app_icons.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/features/onboarding/data/model/bank_model.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:naira_sms_pulse/features/onboarding/presentation/widgets/onboarding_button.dart';

class SelectBankPage extends StatefulWidget {
  SelectBankPage({super.key, required this.bankList});
  List<BankModel> bankList;

  @override
  State<SelectBankPage> createState() => _SelectBankPageState();
}

class _SelectBankPageState extends State<SelectBankPage> {
  @override
  Widget build(BuildContext context) {
    final double itemWidth = (MediaQuery.of(context).size.width - (32)) / 3;
    // Estimate height needed (Icon 50 + Text 40 + Padding 20) = ~110
    final double desiredHeight = 130;
    return SafeArea(
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //----------Header-----------
              //----------Main Text-----------
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.horizontal(context),
                  vertical: Dimensions.extraLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect Accounts',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.secondaryColor,
                            //letterSpacing: -0.5,
                            fontSize: 28,
                          ),
                    ),
                    SizedBox(height: 8),
                    //----------Sub Text-----------
                    Text(
                      "Select the banks where you receive SMS alerts. We'll track your expenses automatically.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.lightGreyTextColor,
                        fontWeight: FontWeight.w500,
                        //height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              if (state.availableBanks.isEmpty && !state.isLoading)
                Center(child: Text('No Available Banks')),

              //----------Grid View-----------
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.horizontal(context),
                  ),
                  itemCount: widget.bankList.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    // childAspectRatio: 0.85, // Taller than wide
                    childAspectRatio:
                        itemWidth / desiredHeight, // 👈 Dynamic Ratio
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final bank = widget.bankList[index];
                    //------- Each Bank Container -------
                    return GestureDetector(
                      onTap: () {
                        context.read<OnboardingCubit>().toggleBanks(bank);
                        // if (_selectedBanks.contains(_dummyBanks[index])) {
                        //   setState(() {
                        //     _selectedBanks.remove(bank);
                        //   });
                        // } else {
                        //   setState(() {
                        //     _selectedBanks.add(bank);
                        //   });
                        // }
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: Dimensions.large),
                        decoration: BoxDecoration(
                          color: AppColors.whitishGreyTextColor,
                          border: Border.all(
                            color: state.selectedBanks.contains(bank)
                                ? AppColors.greyAccentColor
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(100),
                              child: _buildBankHolder(bank.logoUrl),
                            ),
                            SizedBox(height: 8),
                            Flexible(
                              child: Text(
                                bank.name,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppColors.secondaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),

                                textAlign: TextAlign.center,
                                //     maxLines: , // Allow 2 lines max
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              //----------Buttom Contaier and Button-----------
              Container(
                padding: EdgeInsets.all(Dimensions.horizontal(context)),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryColor.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),

                //Button
                // child: SizedBox(
                //   height: Dimensions.smallbuttonHeight,
                //   width: double.infinity,
                //   child: FilledButton(
                // onPressed: _selectedBanks.isEmpty
                //     ? null
                //     : () {
                //         print('Hiii');
                //       },
                //     style: FilledButton.styleFrom(
                //       backgroundColor: AppColors.greyAccentColor,
                //       disabledBackgroundColor: AppColors.middleGreyColor,
                //       // foregroundColor: AppColors.primaryColor,
                //       // disabledForegroundColor: AppColors.greyAccentColor,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadiusGeometry.circular(10),
                //       ),
                //     ),
                //     child: Text(
                //       'Continue',
                // style: _selectedBanks.isEmpty
                //     ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                //         color: AppColors.greyAccentColor,
                //       )
                //     : Theme.of(context).textTheme.bodyLarge?.copyWith(
                //         color: AppColors.primaryColor,
                //       ),
                //     ),
                //   ),
                // ),
                child: OnboardingButton(
                  onPressed: (state.selectedBanks.isEmpty || state.isLoading)
                      ? null
                      : () {
                          context.read<OnboardingCubit>().nextPage();
                        },
                  backgroundColor: AppColors.greyAccentColor,
                  disabledBackgroundColor: AppColors.middleGreyColor,
                  text: 'Continue',
                  style: state.selectedBanks.isEmpty
                      ? Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: AppColors.greyAccentColor,
                        )
                      : Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: AppColors.primaryColor,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBankHolder(String? iconUrl) {
    if (iconUrl == null || iconUrl.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          Icons.account_balance,
          size: 30,
          color: AppColors.lightGreyTextColor,
        ),
      );
    }

    return SvgPicture.network(
      iconUrl,
      height: 50,
      width: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            Icons.account_balance,
            size: 40,
            color: AppColors.greyTextColor,
          ),
        );
      },
    );
  }
}
