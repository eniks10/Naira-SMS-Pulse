// import 'package:flutter/material.dart';

// class BankSelectionPage extends StatefulWidget {
//   const BankSelectionPage({super.key});

//   @override
//   State<BankSelectionPage> createState() => _BankSelectionPageState();
// }

// class _BankSelectionPageState extends State<BankSelectionPage> {
//   // 1. Local State to track selection (Tesla-Simple)
//   // We store the 'ID' of the selected banks.
//   final Set<int> _selectedBankIds = {};

//   // 2. Dummy Data (We will replace this with Supabase data later)
//   final List<Map<String, dynamic>> _dummyBanks = [
//     {'id': 1, 'name': 'GTBank', 'logo': 'assets/gtbank.png'},
//     {'id': 2, 'name': 'UBA', 'logo': 'assets/uba.png'},
//     {'id': 3, 'name': 'Access', 'logo': 'assets/access.png'},
//     {'id': 4, 'name': 'Zenith', 'logo': 'assets/zenith.png'},
//     {'id': 5, 'name': 'Kuda', 'logo': 'assets/kuda.png'},
//     {'id': 6, 'name': 'OPay', 'logo': 'assets/opay.png'},
//     {'id': 7, 'name': 'First Bank', 'logo': 'assets/first.png'},
//     {'id': 8, 'name': 'PalmPay', 'logo': 'assets/palmpay.png'},
//   ];

//   void _toggleSelection(int id) {
//     setState(() {
//       if (_selectedBankIds.contains(id)) {
//         _selectedBankIds.remove(id);
//       } else {
//         _selectedBankIds.add(id);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Or your app's background color
//       body: SafeArea(
//         child: Column(
//           children: [
//             // --- HEADER ---
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Connect Accounts",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Select the banks where you receive SMS alerts. We'll track your expenses automatically.",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey[600],
//                       height: 1.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // --- GRID LIST ---
//             Expanded(
//               child: GridView.builder(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3, // 3 Banks per row
//                   childAspectRatio: 0.85, // Taller than wide
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                 ),
//                 itemCount: _dummyBanks.length,
//                 itemBuilder: (context, index) {
//                   final bank = _dummyBanks[index];
//                   final isSelected = _selectedBankIds.contains(bank['id']);

//                   return _BankCard(
//                     name: bank['name'],
//                     // For now, we use a placeholder icon if you don't have assets yet
//                     // Once you have Supabase, we switch to NetworkImage
//                     child: const Icon(
//                       Icons.account_balance,
//                       size: 30,
//                       color: Colors.grey,
//                     ),
//                     isSelected: isSelected,
//                     onTap: () => _toggleSelection(bank['id']),
//                   );
//                 },
//               ),
//             ),

//             // --- BOTTOM BUTTON ---
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, -5),
//                   ),
//                 ],
//               ),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton(
//                   onPressed: _selectedBankIds.isEmpty
//                       ? null // Disable if nothing selected
//                       : () {
//                           // TODO: Trigger Bloc Event here
//                           print("Selected: $_selectedBankIds");
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue[800], // Your brand color
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     disabledBackgroundColor: Colors.grey[200],
//                   ),
//                   child: const Text(
//                     "Continue",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --- EXTRACTED WIDGET (The "Chip") ---
// class _BankCard extends StatelessWidget {
//   final String name;
//   final Widget child;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _BankCard({
//     required this.name,
//     required this.child,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? Colors.blue[50]
//               : Colors.grey[50], // Light blue bg when active
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isSelected
//                 ? Colors.blue
//                 : Colors.transparent, // Blue border when active
//             width: 2,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // The Logo Circle
//             Container(
//               height: 50,
//               width: 50,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 5,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Center(child: child),
//             ),
//             const SizedBox(height: 12),
//             // The Name
//             Text(
//               name,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                 color: isSelected ? Colors.blue[900] : Colors.black87,
//                 fontSize: 13,
//               ),
//             ),
//             // Optional Checkmark
//             if (isSelected)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Icon(Icons.check_circle, size: 16, color: Colors.blue),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/features/auth/presentation/widgets/auth_button.dart';

class SmsPermissionPage extends StatelessWidget {
  static const String routeName = 'sms_permission_page';

  const SmsPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.horizontal(context),
            vertical: Dimensions.horizontal(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 1. Hero Image / Icon (Use a Lock or Message Shield icon)
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.mark_email_read_outlined, // Or use SvgPicture
                    size: 60,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 2. The Title
              Text(
                "Enable Auto-Tracking",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // 3. The "Trust" Explanation
              Text(
                "To automatically track your expenses, Pulse needs to read your transaction SMS alerts.\n\nWe strictly filter for bank alerts only. Your personal messages remain private and are never read or stored.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.greyTextColor,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // 4. The Action Button
              AuthButton(
                backGroundColor: AppColors.secondaryColor,
                widget: Text(
                  'Grant Permission',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                borderSide: BorderSide.none,
                onPressed: () {
                  // TODO: Trigger Permission Handler Logic
                  // On Success -> Navigate to Home Dashboard
                },
              ),

              const SizedBox(height: 20),

              // 5. "Not Now" Option (Optional)
              TextButton(
                onPressed: () {
                  // TODO: Navigate to Home (Manual Mode)
                },
                child: Text(
                  "I'll add transactions manually",
                  style: TextStyle(
                    color: AppColors.greyAccentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
