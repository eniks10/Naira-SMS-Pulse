class CategoryModel {
  final int id;
  final String name;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.isDefault,
  });

  static List<CategoryModel> get defaultCategories => [
    CategoryModel(id: 1, name: 'Food & Groceries', isDefault: true),
    CategoryModel(id: 2, name: 'Transport', isDefault: true),
    CategoryModel(id: 3, name: 'Data & Airtime', isDefault: true),
    CategoryModel(id: 4, name: 'Utilities', isDefault: true),
    CategoryModel(id: 5, name: 'Subscriptions', isDefault: true),
    CategoryModel(id: 6, name: 'Fuel', isDefault: true),
    CategoryModel(id: 8, name: 'Investment', isDefault: true),
    CategoryModel(id: 9, name: 'Savings', isDefault: true),
    CategoryModel(id: 10, name: 'Rent', isDefault: true),
    CategoryModel(id: 11, name: 'Withdraw & POS', isDefault: true),
    CategoryModel(id: 12, name: 'Giving', isDefault: true),
    CategoryModel(id: 13, name: 'Unknown', isDefault: true),
  ];
}
