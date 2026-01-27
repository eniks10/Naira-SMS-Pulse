import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/features/activity/presentation/pages/activity_page.dart';
import 'package:naira_sms_pulse/features/home/presentation/pages/home_page.dart';
import 'package:naira_sms_pulse/features/insights/presentation/pages/insights_page.dart';
import 'package:naira_sms_pulse/features/main_layout/presentation/cubit/navnavidation_cubit.dart';
import 'package:naira_sms_pulse/service_locater.dart';

class MainLayoutPage extends StatefulWidget {
  static const String routeName = 'main_layout_page';
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  final List<Widget> _pages = const [
    HomePage(),
    ActivityPage(),
    InsightsPage(),
    // HomePage(),

    // ActivityPage(),
    // SettingsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavnavidationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: IndexedStack(index: currentIndex, children: _pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              // 2. Use the Cubit to change tabs
              onDestinationSelected: (index) {
                context.read<NavnavidationCubit>().changeTab(index);
              },
              backgroundColor: Colors.white,
              indicatorColor: AppColors.secondaryColor.withOpacity(0.1),
              elevation: 0,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.secondaryColor,
                  ),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.secondaryColor,
                  ),
                  label: 'Activity',
                ),
                NavigationDestination(
                  icon: Icon(Icons.pie_chart_outline_rounded),
                  selectedIcon: Icon(
                    Icons.pie_chart_rounded,
                    color: AppColors.secondaryColor,
                  ),
                  label: 'Insights',
                ),

                // NavigationDestination(
                //   icon: Icon(Icons.person_outline_rounded),
                //   selectedIcon: Icon(
                //     Icons.person_rounded,
                //     color: AppColors.secondaryColor,
                //   ),
                //   label: 'Profile',
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
