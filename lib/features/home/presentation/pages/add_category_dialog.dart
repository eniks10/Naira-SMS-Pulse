import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:naira_sms_pulse/core/config/asset/app_icons.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/core/helpers/validators.dart';
import 'package:naira_sms_pulse/core/utils/icon_serializer.dart';

class AddCategoryBottomSheet extends StatefulWidget {
  const AddCategoryBottomSheet({
    super.key,
    required this.existingCategories,
    required this.usedIcons,
  });
  final List<String> existingCategories;
  final List<IconData> usedIcons;

  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  final TextEditingController _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // 2. The Smart List Variable
  late List<String> _smartSuggestions;
  late List<IconData> _randomQuickIcons;

  // 3. A Master Pool of ideas (The larger, the better)
  final List<String> _masterPool = [
    'Barber',
    'Hair & Nails',
    'Gym',
    'Data & Airtime',
    'Cinema',
    'Electricity',
    'Rent',
    'Car Repairs',
    'Fuel',
    'Dining Out',
    'Investments',
    'Emergency Fund',
    'Charity',
    'Books',
    'Tuition',
    'Gaming',
    'Pets',
    'Vacation',
  ];

  // 3. MASTER POOL OF ICONS (Relevant categories only)
  final List<IconData> _iconMasterPool = [
    Icons.fastfood_rounded,
    Icons.restaurant_rounded,
    Icons.local_pizza_rounded,
    Icons.directions_car_rounded,
    Icons.local_gas_station_rounded,
    Icons.flight_takeoff_rounded,
    Icons.shopping_bag_rounded,
    Icons.shopping_cart_rounded,
    Icons.credit_card_rounded,
    Icons.receipt_long_rounded,
    Icons.lightbulb_rounded,
    Icons.water_drop_rounded,
    Icons.wifi_rounded,
    Icons.phone_android_rounded,
    Icons.laptop_rounded,
    Icons.checkroom_rounded,
    Icons.local_laundry_service_rounded,
    Icons.spa_rounded,
    Icons.fitness_center_rounded,
    Icons.sports_soccer_rounded,
    Icons.pool_rounded,
    Icons.school_rounded,
    Icons.menu_book_rounded,
    Icons.child_friendly_rounded,
    Icons.pets_rounded,
    Icons.local_hospital_rounded,
    Icons.medical_services_rounded,
    Icons.home_rounded,
    Icons.chair_rounded,
    Icons.construction_rounded,
    Icons.savings_rounded,
    Icons.account_balance_rounded,
    Icons.attach_money_rounded,
    Icons.card_giftcard_rounded,
    Icons.celebration_rounded,
    Icons.movie_rounded,
    Icons.music_note_rounded,
    Icons.gamepad_rounded,
    Icons.camera_alt_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _generateSmartSuggestions();
    _generateRandomIcons();
  }

  // --- LOGIC: Pick 5 Random Icons ---
  void _generateRandomIcons() {
    // 3. FILTER LOGIC
    // Only keep icons that are NOT in the usedIcons list
    final available = _iconMasterPool.where((icon) {
      return !widget.usedIcons.contains(icon);
    }).toList();

    // Safety Fallback: If they used almost all icons, just use the full pool
    // so the list isn't empty.
    final poolToUse = available.length < 5 ? _iconMasterPool : available;

    // 4. Shuffle & Pick 5
    // We create a new list from the pool so we can shuffle it safely
    final shuffled = List<IconData>.from(poolToUse)..shuffle();

    _randomQuickIcons = shuffled.take(5).toList();

    // Set default selection
    if (_randomQuickIcons.isNotEmpty) {
      _selectedIcon = _randomQuickIcons.first;
    }
  }

  void _generateSmartSuggestions() {
    // A. Filter out what they already have (Case insensitive check)
    final available = _masterPool.where((suggestion) {
      return !widget.existingCategories.any(
        (existing) => existing.toLowerCase() == suggestion.toLowerCase(),
      );
    }).toList();

    // B. Shuffle to keep it fresh
    available.shuffle();

    // C. Take the top 4 (or less if we run out)
    _smartSuggestions = available.take(4).toList();

    // Fallback: If they have everything, show generic ones
    if (_smartSuggestions.isEmpty) {
      _smartSuggestions = ['Misc', 'Other', 'General'];
    }
  }

  // 3. State
  IconData _selectedIcon = Icons.category_rounded; // Just a placeholder
  bool _isCustomIconSelected =
      false; // Tracks if the user picked from the library

  // --- THE ICON PICKER LOGIC ---
  Future<void> _pickFromLibrary() async {
    IconPickerIcon? result = await showIconPicker(
      context,
      configuration: SinglePickerConfiguration(
        iconPackModes: [
          IconPack.material,
          IconPack.cupertino,
          IconPack.fontAwesomeIcons,
          IconPack.lineAwesomeIcons,
        ],
        searchHintText: 'Search (e.g. Book, Car...)',
        title: const Text('Select Icon'),
        closeChild: _buildButton(context),
        iconColor: AppColors.secondaryColor,
        backgroundColor: Colors.white,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedIcon = result.data;
        _isCustomIconSelected = true; // Mark that we are using a library icon
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Drag Handle ---
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Create a Category",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.thinGreyColor,
                      ),
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
            ),

            const SizedBox(height: 5),
            Divider(color: AppColors.greyishColor),
            Flexible(
              fit: FlexFit
                  .loose, // 👈 KEY: Allows scrolling without forcing full height
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. Input Field ---
                        const Text(
                          'Category Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          cursorColor: AppColors.secondaryColor,
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Transportation',

                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) =>
                              Validators.validateCategoryCreation(value),
                        ),
                        const SizedBox(height: 16),

                        // --- 2. Suggestion Chips ---
                        Wrap(
                          spacing: 8,
                          children: _smartSuggestions.map((suggestion) {
                            return ActionChip(
                              label: Text(suggestion),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onPressed: () {
                                setState(() {
                                  _nameController.text = suggestion;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // --- 3. Icon Selector (Horizontal List) ---
                        const Text(
                          'Select Icon',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            // Count = Quick icons + 1 (The "More/Custom" button)
                            itemCount: _randomQuickIcons.length + 1,
                            itemBuilder: (context, index) {
                              // --- A. THE "MORE / CUSTOM" BUTTON (Last Item) ---
                              if (index == _randomQuickIcons.length) {
                                bool isCustomActive = _isCustomIconSelected;

                                return GestureDetector(
                                  onTap:
                                      _pickFromLibrary, // Opens flutter_iconpicker
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: isCustomActive
                                          ? AppColors.primaryColor
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                      border: isCustomActive
                                          ? Border.all(
                                              color: AppColors.secondaryColor,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Icon(
                                      // Show selected custom icon OR the arrow down
                                      isCustomActive
                                          ? _selectedIcon
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: isCustomActive
                                          ? AppColors.secondaryColor
                                          : Colors.grey.shade600,
                                      size: 28,
                                    ),
                                  ),
                                );
                              }

                              // --- B. THE QUICK ICONS ---
                              final icon = _randomQuickIcons[index];
                              // It is selected ONLY if it matches AND we haven't picked a custom one
                              final isSelected =
                                  !_isCustomIconSelected &&
                                  icon == _selectedIcon;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIcon = icon;
                                    _isCustomIconSelected =
                                        false; // Reset custom flag
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : AppColors.thinGreyColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        icon,
                                        color: isSelected
                                            ? AppColors.secondaryColor
                                            : Colors.grey.shade400,
                                        size: 28,
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: AppColors.secondaryColor,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- 4. Create Button ---
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SizedBox(
                            width: double.infinity,
                            height: Dimensions.smallbuttonHeight,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_nameController.text.isNotEmpty) {
                                    // Serialize and Return
                                    final iconJson = IconSerializer.serialize(
                                      _selectedIcon,
                                    );
                                    print(_nameController.text);
                                    print(iconJson);
                                    Navigator.pop(context, {
                                      'name': _nameController.text.trim(),
                                      'iconData': iconJson,
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,

                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: AppColors.secondaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Create Category',
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(color: AppColors.secondaryColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimensions.smallbuttonHeight,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.secondaryColor),
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Close', // Changed text
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: AppColors.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
