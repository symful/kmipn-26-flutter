import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/client.dart' show Category;

/// Persists the server catalog with its original string IDs for offline forms.
class CategoryRepository {
  CategoryRepository({required this.accountId});
  final String? accountId;
  String get _key => 'category_catalog_${accountId ?? "guest"}';

  Future<List<Category>> getCachedCategories() async {
    final saved = (await SharedPreferences.getInstance()).getString(_key);
    if (saved == null) return [];
    final rows = jsonDecode(saved) as List;
    return rows
        .map((row) => Category.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _key,
      jsonEncode(categories.map((category) => category.toJson()).toList()),
    );
  }
}
