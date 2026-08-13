import 'package:drift/drift.dart';
import '../database.dart';

class CategoryRepository {
  final AppDatabase _db;
  CategoryRepository(this._db);

  Future<List<LocalCategory>> getCachedCategories() async {
    final query = _db.select(_db.localCategories)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.get();
  }

  Future<void> saveCategories(List<Map<String, dynamic>> categories) async {
    await _db.transaction(() async {
      // Clear old categories and insert new ones
      await _db.delete(_db.localCategories).go();
      for (final cat in categories) {
        await _db
            .into(_db.localCategories)
            .insert(
              LocalCategoriesCompanion(
                id: Value(cat['id'] as int? ?? 0),
                name: Value(cat['name'] as String? ?? ''),
                iconName: Value(cat['icon'] as String?),
                sortOrder: Value((cat['sort_order'] as int?) ?? 0),
              ),
            );
      }
    });
  }

  Future<void> saveCategory(LocalCategoriesCompanion category) async {
    await _db.into(_db.localCategories).insertOnConflictUpdate(category);
  }
}
