import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/scanned_food_model.dart';

class BarcodeLookupException implements Exception {
  final String message;
  BarcodeLookupException(this.message);
  @override
  String toString() => message;
}

class BarcodeLookupService {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';

  static Future<ScannedFoodModel> lookup(String barcode) async {
    final uri = Uri.parse('$_baseUrl/$barcode.json');

    http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw BarcodeLookupException('No internet connection — barcode lookup needs network access.');
    }

    if (response.statusCode != 200) {
      throw BarcodeLookupException('Lookup failed (${response.statusCode}). Try again.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 1 || data['product'] == null) {
      throw BarcodeLookupException('Product not found. Try Custom Dish instead.');
    }

    final product = data['product'] as Map<String, dynamic>;
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    final name = (product['product_name'] as String?)?.trim();
    if (name == null || name.isEmpty) {
      throw BarcodeLookupException('Product found but has no name on record.');
    }

    final calories = _readNum(nutriments['energy-kcal_100g']) ?? _readNum(nutriments['energy-kcal']);
    final protein = _readNum(nutriments['proteins_100g']);
    final carbs = _readNum(nutriments['carbohydrates_100g']);
    final fats = _readNum(nutriments['fat_100g']);

    if (calories == null) {
      throw BarcodeLookupException('This product has no calorie data on record.');
    }

    return ScannedFoodModel(
      name: name,
      barcode: barcode,
      caloriesPer100g: calories.round(),
      proteinPer100g: protein ?? 0,
      carbsPer100g: carbs ?? 0,
      fatsPer100g: fats ?? 0,
    );
  }

  static double? _readNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}