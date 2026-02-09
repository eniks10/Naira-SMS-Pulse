import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:naira_sms_pulse/core/config/asset/app_icons.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/alerts.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/core/models/transaction_model.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:naira_sms_pulse/features/home/presentation/bloc/home_state.dart';
import 'package:naira_sms_pulse/features/home/presentation/pages/transaction_details_page.dart';
import 'package:naira_sms_pulse/features/home/presentation/widgets/pulse_card.dart';
import 'package:naira_sms_pulse/features/home/presentation/widgets/transaction_tile.dart';
import 'package:naira_sms_pulse/features/main_layout/presentation/cubit/navnavidation_cubit.dart';

class HomePage extends StatefulWidget {
  static const routeName = 'home_page';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Triggers the initial load (Default: All Banks)
    context.read<HomeBloc>().add(LoadDashBoardEvent());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final String firstName =
        user?.userMetadata?['full_name']?.split(' ').first ?? 'User';

    return Scaffold(
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.errorMessage.isNotEmpty) {
            print(state.errorMessage);
            AppAlerts.showError(context: context, error: state.errorMessage);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: RefreshIndicator(
              backgroundColor: AppColors.primaryColor,
              onRefresh: () async =>
                  context.read<HomeBloc>().add(RefreshEvent()),
              color: AppColors.secondaryColor,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
          

                  // 2. GREETING
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.horizontal(context),
                      ).copyWith(bottom: 10, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // _getGreeting(),
                            'Hello $firstName,',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.secondaryColor,
                                  // wordSpacing: -5,
                                  letterSpacing: -1,
                                ),
                          ),

                  
                        ],
                      ),
                    ),
                  ),

                  // 3. THE PULSE CARD (Updated Titles) 💳
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.horizontal(context),
                      ),
                      child: PulseCard(
                        totalSpent: state.totalSpent,
                        totalIncome: state.totalIncome,
                        // 🚀 UPDATED TITLE LOGIC:
                        // Since Bloc now returns "Weekly" expense, we label it correctly.
                        title: state.selectedBankIndex == 0
                            ? 'All'
                            : '${state.selectedbanks[state.selectedBankIndex - 1].name} ',
                        state: state,
                        onTap: () {
                          showFloatingBottomDialog(context, state);
                        },
                      ),
                    ),
                  ),

                  // 4. SECTION HEADER ("Recent Transactions")
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.horizontal(context),
                      ).copyWith(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              "Recent Transactions",
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondaryColor,
                                    letterSpacing: 0,
                                    fontSize: 16,
                                  ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<NavnavidationCubit>().changeTab(2);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                            ),
                            child: Text(
                              "See All",
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightGreyTextColor,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. LOADING STATE
                  if (state.isLoading && state.transactions.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // 6. EMPTY STATE
                  if (!state.isLoading && state.transactions.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.horizontal(context),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_list_off_rounded,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No recent transactions\nfound.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 7. THE LIST
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final txn = state.transactions[index];
                        final IconData icon =
                            state.categoryIcons[txn.categoryName] ??
                            Icons.category_rounded;
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            TransactionDetailsPage.routeName,
                            arguments: {
                              'transaction': txn,

                              // Pass Data
                              'categoryNames': state.categoryNames,
                              'categoryIcons': state.categoryIcons,

                              // Pass Functions
                              'onCategoryChanged':
                                  (
                                    TransactionModel transaction,
                                    String newCategory,
                                  ) {
                                    context.read<HomeBloc>().add(
                                      ChangeCategoryEvent(
                                        transaction,
                                        newCategory,
                                      ),
                                    );
                                  },
                              'onCategoryAdded':
                                  (String name, String iconData) {
                                    context.read<HomeBloc>().add(
                                      AddNewCategoryEvent(
                                        name: name,
                                        iconJson: iconData,
                                      ),
                                    );
                                  },

                              'onPartyChanged':
                                  (
                                    TransactionModel transaction,
                                    String newName,
                                  ) {
                                    context.read<HomeBloc>().add(
                                      UpdateTransactionPartyEvent(
                                        transaction: transaction,
                                        name: newName,
                                      ),
                                    );
                                  },
                            },
                          ),
                          child: TransactionTile(
                            transaction: txn,
                            categoryIcon: icon,
                          ),
                        );
                      },
                      childCount: state.transactions.length > 5
                          ? 10
                          : state.transactions.length,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showFloatingBottomDialog(BuildContext context, HomeState state) {
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
                      itemCount: state.selectedbanks.length + 1,
                      itemBuilder: (context, index) {
                        bool isAllAccounts = index == 0;

                        // Logic: If index is 0, bank is null. Else, shift index by 1.
                        final bank = isAllAccounts
                            ? null
                            : state.selectedbanks[index - 1];

                        // Check if this row is selected
                        bool isSelected = state.selectedBankIndex == index;

                        return GestureDetector(
                          onTap: () {
                            context.read<HomeBloc>().add(
                              BankChangedEvent(index: index),
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

  Widget _buildBankHolder(HomeState state, int index) {
    if (state.selectedBankIndex == 0 ||
        state.selectedbanks[state.selectedBankIndex - 1].logoUrl == null) {
      return Icon(
        Icons.account_balance,
        size: 20,
        color: AppColors.lightGreyTextColor,
      );
    }

    return SvgPicture.network(
      state.selectedbanks[state.selectedBankIndex - 1].logoUrl!,
      height: 20,
      width: 20,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.account_balance,
          size: 14,
          color: AppColors.greyTextColor,
        );
      },
    );
  }
}
