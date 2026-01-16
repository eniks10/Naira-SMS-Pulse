// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
// import 'package:naira_sms_pulse/features/home/presentation/bloc/home_bloc.dart';
// import 'package:naira_sms_pulse/features/home/presentation/bloc/home_state.dart';
// import 'package:naira_sms_pulse/features/home/presentation/widgets/pulse_card.dart';

// class BankCardSelector extends StatefulWidget {
//   const BankCardSelector({super.key});

//   @override
//   State<BankCardSelector> createState() => _BankCardSelectorState();
// }

// class _BankCardSelectorState extends State<BankCardSelector> {
//   final PageController _controller = PageController(viewportFraction: 0.92);

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<HomeBloc, HomeState>(
//       builder: (context, state) {
//         // 1. Determine Total Page Count (1 for "All" + count of banks)
//         final int itemCount = 1 + state.availableBanks.length;

//         return SizedBox(
//           height: 200, // Height of the card area
//           child: PageView.builder(
//             controller: _controller,
//             itemCount: itemCount,
//             onPageChanged: (index) {
//               // 🚀 Trigger the Filter Event
//               context.read<HomeBloc>().add(BankChangedEvent(index: index));
//             },
//             itemBuilder: (context, index) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 5),
//                 child: _buildCardContent(context, state, index),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCardContent(BuildContext context, HomeState state, int index) {
//     // If we are currently loading, show a skeleton or loading state
//     // But since we update state instantly, we can just show the data.

//     // Determine Label & Color
//     String cardTitle;
//     Color color1;
//     Color color2;

//     if (index == 0) {
//       // "All" Card
//       cardTitle = "Total Spent (All Accounts)";
//       color1 = AppColors.secondaryColor;
//       color2 = AppColors.secondaryColor.withOpacity(0.8);
//     } else {
//       // Specific Bank Card
//       final bank = state.availableBanks[index - 1];
//       cardTitle = "${bank.bankName} Summary";

//       // Tesla Polish: Use different colors for different banks?
//       // For now, let's use a slightly different shade or brand color if available
//       color1 = Colors.blueGrey.shade800;
//       color2 = Colors.blueGrey.shade600;
//     }

//     // Reuse your beautiful PulseCard widget, but make it customizable!
//     // (You might need to update PulseCard to accept title/colors)
//     return PulseCard(
//       totalSpent: state.totalSpent,
//       totalIncome: state.totalIncome,
//       title: cardTitle, // 👈 Update PulseCard to accept this
//       gradientColors: [color1, color2], // 👈 Update PulseCard to accept this
//     );
//   }
// }
