import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arzo_real_estate/app.dart';
import 'package:arzo_real_estate/data/app_store.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Pixso flows, persistence, light and dark screenshots', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final store = AppStore(prefs);
    await tester.pumpWidget(ArzoApp(store: store));
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    final captureDirectory = await Directory(
      '${Directory.systemTemp.path}/arzo-captures',
    ).create(recursive: true);
    final capturedNames = <String>[];

    Future<void> tap(Finder finder) async {
      await tester.ensureVisible(finder.first);
      await tester.tap(finder.first);
      await tester.pumpAndSettle();
    }

    Future<void> button(String text) => tap(
      find.ancestor(
        of: find.text(text),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    Future<void> shot(String name) async {
      FocusManager.instance.primaryFocus?.unfocus();
      // A later enterText on this same field must reopen its input connection.
      binding.focusedEditable = null;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(tester.takeException(), isNull);
      final capture = await binding.takeScreenshot(name);
      await File('${captureDirectory.path}/$name.png').writeAsBytes(capture);
      capturedNames.add(name);
      // Export files after the run instead of sending every PNG as a huge JSON list.
      binding.reportData!.remove('screenshots');
      binding.reportData!['captureDirectory'] = captureDirectory.path;
      binding.reportData!['captureNames'] = capturedNames;
    }

    Future<void> back() => tap(find.byTooltip('Back'));
    Future<void> tab(int i) => tap(find.byKey(Key('tab-$i')));

    await shot('01-onboarding-discover');
    await button('Next');
    await shot('02-onboarding-find');
    await button('Next');
    await shot('03-onboarding-start');
    await button('Get Started');
    await shot('04-sign-in');
    await button('Sign In');
    expect(find.text('Enter a valid email address'), findsOneWidget);
    await shot('04a-sign-in-validation');
    await tap(find.text('Forgot Password?'));
    await shot('05-forgot-password');
    await tester.enterText(
      find.byType(TextFormField).first,
      'alex@example.com',
    );
    await button('Send Reset Link');
    await shot('06-reset-link');
    await button('Create New Password');
    await shot('07-reset-password');
    await tester.enterText(find.byType(TextFormField).at(0), 'newpass123');
    await tester.enterText(find.byType(TextFormField).at(1), 'newpass123');
    await button('Create New Password');
    await tap(find.text('Done'));
    await tap(find.text('I Don’t Have an Account'));
    await shot('08-sign-up');
    await tester.enterText(find.byType(TextFormField).at(0), 'Dorothy Ann');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'dorothyann@gmail.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'demo1234');
    await button('Sign Up');
    await shot('09-neighborhood');
    await tester.enterText(find.byKey(const Key('search-field')), 'Nowhere');
    await tester.pumpAndSettle();
    expect(find.text('Neighborhood Not Found'), findsOneWidget);
    await shot('09a-neighborhood-empty');
    await tap(find.byTooltip('Clear search'));
    await tap(find.text('Los Angeles, California'));
    expect(store.signedIn, isTrue);
    await shot('10-home');
    await tab(2);
    await shot('10a-messages-empty');
    await tab(3);
    await shot('10b-saved-empty');
    await tab(0);
    await tap(find.byKey(const Key('category-Apartment')));
    await shot('11-apartments');
    await tap(find.byKey(const Key('category-All')));
    await tap(find.text('View on Map'));
    await shot('12-map');
    await tester.enterText(find.byKey(const Key('search-field')), 'Nowhere');
    await tester.pumpAndSettle();
    expect(find.text('No Homes Found'), findsOneWidget);
    await shot('12a-map-empty');
    await tap(find.byTooltip('Clear search'));
    await tap(find.byIcon(Icons.home_outlined).last);
    await shot('13-map-selected');
    await back();

    await tap(find.text('Terracota House'));
    await shot('14-property');
    await tester.ensureVisible(find.text('Read more...'));
    await tap(find.text('Read more...'));
    await tester.ensureVisible(find.text('Illustrative market data'));
    await shot('14a-property-description');
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 900),
    );
    await tester.pumpAndSettle();
    await tap(find.byKey(const Key('save-property')));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(store.saved, contains('terracota'));
    await tap(find.text('+2 Photos'));
    await shot('15-gallery');
    await tap(find.byType(GestureDetector).last);
    await shot('16-photo');
    await back();
    await back();
    await tap(find.text('3 Beds'));
    await shot('17-estate-facts');
    await back();
    await tap(find.byIcon(Icons.location_on_rounded).last);
    await shot('18-estate-location');
    await back();
    await tap(find.byTooltip('Message owner'));
    await shot('19-chat');
    await tester.enterText(
      find.byKey(const Key('message-input')),
      'Is this home still available?',
    );
    await tap(find.byKey(const Key('send-message')));
    await shot('20-chat-sent');
    expect(
      store.messages['Angela Wani']!.last.text,
      'Is this home still available?',
    );
    await back();

    await button('Schedule a Tour');
    await shot('21-tour-type');
    await tap(find.byKey(const Key('tour-person')));
    await button('Continue');
    await shot('22-tour-date');
    await button('Continue');
    await shot('23-tour-time');
    await tap(find.byKey(const Key('time-11:00 AM')));
    await button('Continue');
    await shot('24-tour-confirm');
    await button('Confirm Schedule');
    await shot('25-tour-success');
    expect(store.tours.length, 1);
    await button('Explore More Listings');

    await tab(1);
    await shot('26-search');
    await tester.enterText(find.byKey(const Key('search-field')), 'United');
    await shot('27-search-results');
    expect(find.text('United Condos'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search-field')), 'zzzzzz');
    await tester.pumpAndSettle();
    expect(find.text('No Results Found'), findsOneWidget);
    await shot('28-search-empty');
    await tap(find.byTooltip('Clear search'));
    await tap(find.byKey(const Key('category-Owner')));
    await shot('29-search-owners');
    await tab(2);
    await shot('30-messages');
    await tab(3);
    await shot('31-saved');
    await tester.drag(
      find.byKey(const ValueKey('saved-terracota')),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();
    await shot('31a-remove-saved');
    await tap(find.text('Keep it'));
    await tab(4);
    await shot('32-profile');
    await tap(find.text('Change Profile Details'));
    await shot('33-edit-profile');
    await tap(find.text('Use Initials Instead'));
    await shot('33a-profile-initials');
    await tap(find.text('Use Sample Profile Photo'));
    await tester.enterText(find.byType(TextFormField).at(0), 'Dorothy Ann');
    await button('Save Changes');
    await tap(find.text('See Tour Status'));
    await shot('34-tour-list');
    await tap(find.text('Terracota House'));
    await shot('35-tour-status');
    await back();
    await back();
    await tap(find.text('Change Password'));
    await shot('36-change-password');
    await back();
    await tap(find.text('Display and Notification Settings'));
    await shot('37-settings');
    await tap(find.byKey(const Key('dark-switch')));
    await shot('38-settings-dark');
    await back();
    await shot('39-profile-dark');
    await tab(0);
    await shot('40-home-dark');
    await tap(find.text('Terracota House'));
    await button('Schedule a Tour');
    await tap(find.byKey(const Key('tour-video')));
    await button('Continue');
    await shot('41-video-contact');
    await button('Continue');
    await shot('41a-video-date');
    await button('Continue');
    await shot('41b-video-time');
    await tap(find.byKey(const Key('time-2:00 PM')));
    await button('Continue');
    await shot('41c-video-confirm');
    await button('Confirm Schedule');
    await shot('41d-video-success');
    expect(store.tours.length, 2);
    await button('Explore More Listings');
    await tab(4);
    await tap(find.text('See Tour Status'));
    await tap(find.byKey(const Key('category-Live Video')));
    await shot('42-video-tour-list');
    await tap(find.text('Terracota House'));
    await button('Cancel Tour');
    await tap(find.widgetWithText(TextButton, 'Cancel Tour'));
    expect(store.tours.first.status, 'Cancelled');
    await shot('43-tour-cancelled');
    await back();
    await back();
    await tap(find.text('Display and Notification Settings'));
    await tap(find.byKey(const Key('dark-switch')));
    await back();
    await tap(find.text('Logout'));
    await shot('44-logout-confirmation');
    await tap(find.text('Keep it'));
    await tab(0);

    final restored = AppStore(prefs);
    expect(restored.saved, contains('terracota'));
    expect(restored.tours.length, 2);
    expect(
      restored.messages['Angela Wani']!.last.text,
      'Is this home still available?',
    );
    expect(restored.name, 'Dorothy Ann');
    expect(tester.takeException(), isNull);
    // Leave the emulator on the light home screen for review.
  }, timeout: const Timeout(Duration(minutes: 10)));
}
