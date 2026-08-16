import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/features/warga/presentation/screens/warga_app_bar.dart';
import 'package:sigap/widgets/design_system/wilayah_dropdown.dart';
import 'package:sigap/widgets/design_system/offline_pill.dart';
import 'package:sigap/widgets/design_system/notification_bell.dart';

void main() {
  group('WargaAppBar', () {
    testWidgets('renders WilayahDropdown with correct value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WargaAppBar(wilayahName: 'Desa Ciburuy')),
        ),
      );

      expect(find.byType(WilayahDropdown), findsOneWidget);
      expect(find.text('Desa Ciburuy'), findsOneWidget);
    });

    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WargaAppBar(wilayahName: 'Desa Ciburuy')),
        ),
      );

      expect(find.text('Wilayah aktif'), findsOneWidget);
    });

    testWidgets('renders NotificationBell', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: WargaAppBar(wilayahName: 'Desa Ciburuy')),
        ),
      );

      expect(find.byType(NotificationBell), findsOneWidget);
    });

    testWidgets('shows OfflinePill when isOffline is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WargaAppBar(wilayahName: 'Desa Ciburuy', isOffline: true),
          ),
        ),
      );

      expect(find.byType(OfflinePill), findsOneWidget);
    });

    testWidgets('hides OfflinePill when isOffline is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WargaAppBar(wilayahName: 'Desa Ciburuy', isOffline: false),
          ),
        ),
      );

      expect(find.byType(OfflinePill), findsNothing);
    });

    testWidgets('passes unreadCount to NotificationBell', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WargaAppBar(wilayahName: 'Desa Ciburuy', unreadCount: 5),
          ),
        ),
      );

      final notificationBell = tester.widget<NotificationBell>(
        find.byType(NotificationBell),
      );
      expect(notificationBell.unreadCount, 5);
    });

    testWidgets('accepts onWilayahTap callback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WargaAppBar(wilayahName: 'Desa Ciburuy', onWilayahTap: () {}),
          ),
        ),
      );

      // Verify the callback is accepted by finding the widget
      expect(find.byType(WilayahDropdown), findsOneWidget);
    });

    testWidgets('accepts onNotificationTap callback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WargaAppBar(
              wilayahName: 'Desa Ciburuy',
              onNotificationTap: () {},
            ),
          ),
        ),
      );

      // Verify the callback is accepted by finding the widget
      expect(find.byType(NotificationBell), findsOneWidget);
    });
  });

  group('WilayahDropdown', () {
    testWidgets('renders label and value correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: WilayahDropdown(
                  label: 'Wilayah aktif',
                  value: 'Desa Ciburuy',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Wilayah aktif'), findsOneWidget);
      expect(find.text('Desa Ciburuy'), findsOneWidget);
    });

    testWidgets('shows dropdown arrow icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: WilayahDropdown(
                  label: 'Wilayah aktif',
                  value: 'Desa Ciburuy',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('accepts onTap callback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: WilayahDropdown(
                  label: 'Wilayah aktif',
                  value: 'Desa Ciburuy',
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WilayahDropdown), findsOneWidget);
    });

    testWidgets('uses default label when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: WilayahDropdown(value: 'Desa Ciburuy'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Wilayah aktif'), findsOneWidget);
    });
  });
}
