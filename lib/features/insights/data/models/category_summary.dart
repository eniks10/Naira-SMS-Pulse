import 'package:flutter/material.dart';

class CategorySummary {
  final String name;
  final double totalAmount;
  final double percentage; // 0.0 to 1.0 (e.g. 0.45 for 45%)
  final Color color;
  final IconData icon; // We can map this later

  CategorySummary({
    required this.name,
    required this.totalAmount,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}
