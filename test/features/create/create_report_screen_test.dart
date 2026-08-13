import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:sigap/db/database.dart';
import 'package:sigap/db/repositories/category_repository.dart';
import 'package:sigap/providers/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateReportScreen - Category Error Handling', () {
    late AppDatabase db;
    late CategoryRepository categoryRepo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      categoryRepo = CategoryRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets(
      'shows error widget when categoriesProvider returns empty and cache is empty',
      (tester) async {
        // Override providers to simulate empty cache scenario
        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            categoryRepositoryProvider.overrideWithValue(categoryRepo),
            // categoriesProvider will use the real implementation which falls back to cache
            // but we need to ensure cache is empty
          ],
        );

        // Ensure cache is empty
        final cachedBefore = await container
            .read(categoryRepositoryProvider)
            .getCachedCategories();
        expect(cachedBefore, isEmpty);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(body: _TestCategorySection()),
            ),
          ),
        );

        // Wait for FutureBuilder to complete
        await tester.pumpAndSettle();

        // Should show error widget with "Tidak ada kategori tersedia"
        expect(find.text('Tidak ada kategori tersedia'), findsOneWidget);

        // Should show retry button
        expect(find.text('Coba Lagi'), findsOneWidget);

        // Should NOT show any hardcoded category names
        expect(find.text('Jalan Rusak'), findsNothing);
        expect(find.text('Jembatan Rusak'), findsNothing);
        expect(find.text('Drainase Tersumbat'), findsNothing);
        expect(find.text('Fasilitas Umum'), findsNothing);

        container.dispose();
      },
    );
  });
}

/// Test widget that mirrors the _CategorySection behavior
class _TestCategorySection extends ConsumerWidget {
  const _TestCategorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => _buildErrorWidget(context, ref, error.toString()),
      data: (categories) {
        if (categories.isEmpty) {
          return _buildCacheFallback(context, ref);
        }
        return Text('Categories: ${categories.length}');
      },
    );
  }

  Widget _buildCacheFallback(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<LocalCategory>>(
      future: ref.read(categoryRepositoryProvider).getCachedCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildErrorWidget(context, ref, 'Tidak ada kategori tersedia');
        }
        return Text('Cached: ${snapshot.data!.length}');
      },
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    WidgetRef ref,
    String message,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Kategori',
            errorText: null,
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Coba Lagi'),
          onPressed: () => ref.invalidate(categoriesProvider),
        ),
      ],
    );
  }
}
