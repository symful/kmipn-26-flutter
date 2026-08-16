import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/widgets/m14_timeline.dart';
import 'package:sigap/theme/tokens.dart';

void main() {
  group('M14Timeline', () {
    testWidgets('renders default header text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M14Timeline(events: [])),
        ),
      );

      expect(find.text('Perjalanan laporan'), findsOneWidget);
    });

    testWidgets('renders custom header text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: M14Timeline(events: [], headerText: 'Riwayat Perubahan'),
          ),
        ),
      );

      expect(find.text('Riwayat Perubahan'), findsOneWidget);
      expect(find.text('Perjalanan laporan'), findsNothing);
    });

    testWidgets('renders header with correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M14Timeline(events: [])),
        ),
      );

      final header = tester.widget<Text>(find.text('Perjalanan laporan'));
      expect(header.style?.fontSize, AppTypography.size12);
      expect(header.style?.fontWeight, FontWeight.w700);
      expect(header.style?.color, AppColors.textTertiary);
      expect(header.style?.letterSpacing, AppTypography.letterSpacingLabel);
    });

    testWidgets('renders single event with title and meta', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14Timeline(
              events: const [
                TimelineEvent(
                  title: 'Perlu dilengkapi',
                  meta: '17 Jul, 14:20 · oleh verifikator RW',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Perlu dilengkapi'), findsOneWidget);
      expect(find.text('17 Jul, 14:20 · oleh verifikator RW'), findsOneWidget);
    });

    testWidgets('renders multiple events in order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14Timeline(
              events: const [
                TimelineEvent(
                  title: 'Tersimpan di perangkat',
                  meta: '17 Jul, 09:33 · offline',
                ),
                TimelineEvent(
                  title: 'Sedang diperiksa',
                  meta: '17 Jul, 11:05 · sistem',
                ),
              ],
            ),
          ),
        ),
      );

      // Both titles should be present
      expect(find.text('Tersimpan di perangkat'), findsOneWidget);
      expect(find.text('Sedang diperiksa'), findsOneWidget);
      // Both metas should be present
      expect(find.text('17 Jul, 09:33 · offline'), findsOneWidget);
      expect(find.text('17 Jul, 11:05 · sistem'), findsOneWidget);
    });

    testWidgets('active event shows amber dot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14Timeline(
              events: const [
                TimelineEvent(
                  title: 'Perlu dilengkapi',
                  meta: '17 Jul, 14:20 · oleh verifikator RW',
                  isActive: true,
                ),
              ],
            ),
          ),
        ),
      );

      // Find the Container with BoxDecoration that has the amber color
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundAmberDot = false;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle &&
              decoration.color == AppColors.warning) {
            foundAmberDot = true;
            break;
          }
        }
      }
      expect(foundAmberDot, isTrue);
    });

    testWidgets('normal event shows teal dot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14Timeline(
              events: const [
                TimelineEvent(
                  title: 'Sedang diperiksa',
                  meta: '17 Jul, 11:05 · sistem',
                ),
              ],
            ),
          ),
        ),
      );

      // Find the Container with BoxDecoration that has the primary (teal) color
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundTealDot = false;
      for (final container in containers) {
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.shape == BoxShape.circle &&
              decoration.color == AppColors.primary) {
            foundTealDot = true;
            break;
          }
        }
      }
      expect(foundTealDot, isTrue);
    });

    testWidgets('title uses correct typography', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14Timeline(
              events: const [
                TimelineEvent(
                  title: 'Perlu dilengkapi',
                  meta: '17 Jul, 14:20 · oleh verifikator RW',
                ),
              ],
            ),
          ),
        ),
      );

      final title = tester.widget<Text>(find.text('Perlu dilengkapi'));
      expect(title.style?.fontSize, AppTypography.size13);
      expect(title.style?.fontWeight, FontWeight.w600);
      expect(title.style?.color, AppColors.textPrimary);
    });

    testWidgets('meta uses tabular figures', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14Timeline(
              events: const [
                TimelineEvent(
                  title: 'Perlu dilengkapi',
                  meta: '17 Jul, 14:20 · oleh verifikator RW',
                ),
              ],
            ),
          ),
        ),
      );

      final meta = tester.widget<Text>(
        find.text('17 Jul, 14:20 · oleh verifikator RW'),
      );
      expect(meta.style?.fontSize, AppTypography.size11);
      expect(meta.style?.color, AppColors.textTertiary);
      expect(meta.style?.fontFeatures, contains(FontFeature.tabularFigures()));
    });

    testWidgets('connects events with vertical line', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14Timeline(
              events: const [
                TimelineEvent(
                  title: 'Event 1',
                  meta: '17 Jul, 09:33 · offline',
                ),
                TimelineEvent(title: 'Event 2', meta: '17 Jul, 11:05 · sistem'),
              ],
            ),
          ),
        ),
      );

      // Should have Expanded widgets for the lines
      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('handles empty events list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: M14Timeline(events: [])),
        ),
      );

      // Should only show header, no content
      expect(find.text('Perjalanan laporan'), findsOneWidget);
    });

    testWidgets('last event has no bottom padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: M14Timeline(
              events: const [
                TimelineEvent(
                  title: 'Tersimpan di perangkat',
                  meta: '17 Jul, 09:33 · offline',
                ),
              ],
            ),
          ),
        ),
      );

      // Find the Padding widget that wraps the content
      final paddings = tester.widgetList<Padding>(
        find.descendant(
          of: find.byType(M14Timeline),
          matching: find.byType(Padding),
        ),
      );

      // Should have at least one Padding with zero bottom padding for last item
      bool foundZeroPadding = false;
      for (final padding in paddings) {
        if (padding.padding == EdgeInsets.zero) {
          foundZeroPadding = true;
          break;
        }
      }
      expect(foundZeroPadding, isTrue);
    });
  });

  group('TimelineEvent', () {
    test('creates const instance with required fields', () {
      const event = TimelineEvent(
        title: 'Perlu dilengkapi',
        meta: '17 Jul, 14:20 · oleh verifikator RW',
      );

      expect(event.title, 'Perlu dilengkapi');
      expect(event.meta, '17 Jul, 14:20 · oleh verifikator RW');
      expect(event.isActive, false);
    });

    test('creates const instance with isActive true', () {
      const event = TimelineEvent(
        title: 'Perlu dilengkapi',
        meta: '17 Jul, 14:20 · oleh verifikator RW',
        isActive: true,
      );

      expect(event.isActive, true);
    });
  });
}
