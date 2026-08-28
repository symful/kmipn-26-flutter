import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigap/widgets/design_system/responsive.dart';

void main() {
  group('Breakpoints', () {
    test('mobile constant is 600', () {
      expect(Breakpoints.mobile, 600);
    });

    test('tablet constant is 1024', () {
      expect(Breakpoints.tablet, 1024);
    });
  });

  group('isMobile', () {
    test('returns true for width < 600', () {
      expect(isMobile(375), isTrue);
      expect(isMobile(0), isTrue);
      expect(isMobile(599), isTrue);
    });

    test('returns false for width >= 600', () {
      expect(isMobile(600), isFalse);
      expect(isMobile(800), isFalse);
      expect(isMobile(1024), isFalse);
    });
  });

  group('isTablet', () {
    test('returns true for width 600–1024 inclusive', () {
      expect(isTablet(600), isTrue);
      expect(isTablet(800), isTrue);
      expect(isTablet(1024), isTrue);
    });

    test('returns false for width outside 600–1024', () {
      expect(isTablet(599), isFalse);
      expect(isTablet(1025), isFalse);
    });
  });

  group('isDesktop', () {
    test('returns true for width > 1024', () {
      expect(isDesktop(1280), isTrue);
      expect(isDesktop(1920), isTrue);
      expect(isDesktop(1025), isTrue);
    });

    test('returns false for width <= 1024', () {
      expect(isDesktop(1024), isFalse);
      expect(isDesktop(600), isFalse);
      expect(isDesktop(375), isFalse);
    });
  });

  group('breakpointName', () {
    test('mobile widths return "mobile"', () {
      expect(breakpointName(375), 'mobile');
    });

    test('tablet widths return "tablet"', () {
      expect(breakpointName(800), 'tablet');
    });

    test('desktop widths return "desktop"', () {
      expect(breakpointName(1280), 'desktop');
    });
  });

  group('ResponsiveWidget', () {
    testWidgets('renders mobile widget at width 375', (tester) async {
      String? rendered;

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 375,
              height: 800,
              child: ResponsiveWidget(
                mobile: Builder(
                  builder: (_) {
                    rendered = 'mobile';
                    return const Text('mobile');
                  },
                ),
                tablet: Builder(
                  builder: (_) {
                    rendered = 'tablet';
                    return const Text('tablet');
                  },
                ),
                desktop: Builder(
                  builder: (_) {
                    rendered = 'desktop';
                    return const Text('desktop');
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(rendered, 'mobile');
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('renders tablet widget at width 800', (tester) async {
      String? rendered;

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 800,
              height: 600,
              child: ResponsiveWidget(
                mobile: Builder(
                  builder: (_) {
                    rendered = 'mobile';
                    return const Text('mobile');
                  },
                ),
                tablet: Builder(
                  builder: (_) {
                    rendered = 'tablet';
                    return const Text('tablet');
                  },
                ),
                desktop: Builder(
                  builder: (_) {
                    rendered = 'desktop';
                    return const Text('desktop');
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(rendered, 'tablet');
      expect(find.text('tablet'), findsOneWidget);
    });

    testWidgets('renders desktop widget at width 1280', (tester) async {
      String? rendered;

      // Set test surface size to accommodate 1280 width
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWidget(
            mobile: Builder(
              builder: (_) {
                rendered = 'mobile';
                return const Text('mobile');
              },
            ),
            tablet: Builder(
              builder: (_) {
                rendered = 'tablet';
                return const Text('tablet');
              },
            ),
            desktop: Builder(
              builder: (_) {
                rendered = 'desktop';
                return const Text('desktop');
              },
            ),
          ),
        ),
      );

      expect(rendered, 'desktop');
      expect(find.text('desktop'), findsOneWidget);
    });

    testWidgets('falls back to tablet when mobile is null at mobile width', (
      tester,
    ) async {
      String? rendered;

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 375,
              height: 800,
              child: ResponsiveWidget(
                tablet: Builder(
                  builder: (_) {
                    rendered = 'tablet-fallback';
                    return const Text('tablet-fallback');
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(rendered, 'tablet-fallback');
    });
  });

  group('ResponsiveValue', () {
    test('resolve returns correct value per breakpoint', () {
      const value = ResponsiveValue<String>(
        mobile: 'm',
        tablet: 't',
        desktop: 'd',
      );

      expect(value.resolve(375), 'm');
      expect(value.resolve(800), 't');
      expect(value.resolve(1280), 'd');
    });

    test('resolve returns null when no value for breakpoint', () {
      const value = ResponsiveValue<String>(mobile: 'only-mobile');

      expect(value.resolve(800), isNull);
      expect(value.resolve(1280), isNull);
    });
  });
}
