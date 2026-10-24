import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arzo_real_estate/app.dart';
import 'package:arzo_real_estate/core/widgets.dart';
import 'package:arzo_real_estate/data/app_store.dart';

// These tests exercise layout. Real artwork is verified by the emulator suite.
class _LayoutAssets extends CachingAssetBundle {
  final _pixel = File('test/fixtures/pixel.png').readAsBytesSync();
  @override
  Future<ByteData> load(String key) => key.endsWith('.png')
      ? Future.value(ByteData.sublistView(_pixel))
      : rootBundle.load(key);
}

Widget layoutApp(AppStore store) => DefaultAssetBundle(
  bundle: _LayoutAssets(),
  child: ArzoApp(store: store),
);

void main() {
  testWidgets(
    'empty states remain scrollable when the keyboard reduces space',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 180,
              child: EmptyState(
                title: 'No Homes Found',
                message: 'Try another search or property category.',
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('three onboarding pages fit a small screen with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    SharedPreferences.setMockInitialValues({});
    final store = AppStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(layoutApp(store));
    for (var i = 0; i < 3; i++) {
      final label = i == 2 ? 'Get Started' : 'Next';
      await tester.ensureVisible(find.widgetWithText(FilledButton, label));
      await tester.tap(find.widgetWithText(FilledButton, label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(store.onboarded, isTrue);
  });
  testWidgets('sign in remains usable on a small screen with a keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final store = AppStore(await SharedPreferences.getInstance());
    await store.finishOnboarding();
    await tester.pumpWidget(layoutApp(store));
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'alex@example.com',
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign In'));
    expect(tester.takeException(), isNull);
  });
}
