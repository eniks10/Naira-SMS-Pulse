import 'dart:convert';
import 'package:flutter/material.dart';

class IconSerializer {
  // Convert IconData -> JSON String
  static String serialize(IconData icon) {
    return jsonEncode({
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
      'matchTextDirection': icon.matchTextDirection,
    });
  }

  // Convert JSON String -> IconData
  static IconData deserialize(String jsonString) {
    try {
      Map<String, dynamic> data = jsonDecode(jsonString);
      return IconData(
        data['codePoint'],
        fontFamily: data['fontFamily'],
        fontPackage: data['fontPackage'],
        matchTextDirection: data['matchTextDirection'] ?? false,
      );
    } catch (e) {
      return Icons.category_rounded; // Fallback
    }
  }
}
