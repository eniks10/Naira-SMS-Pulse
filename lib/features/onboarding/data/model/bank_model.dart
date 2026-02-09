class BankModel {
  final int id;
  final String name;
  final List<String> smsSenderName;
  final String? logoUrl;
  final bool isActive;

  BankModel({
    required this.id,
    required this.name,
    required this.smsSenderName,
    this.logoUrl,
    required this.isActive,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'],
      name: json['bank_name'],
      smsSenderName: List<String>.from(json['bank_sms_sender_names'] ?? []),
      logoUrl: json['bank_logo_url'],
      isActive: json['is_active'],
    );
  }
  // Value Equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BankModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
