import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arzo_real_estate/data/app_store.dart';
import 'package:arzo_real_estate/data/models.dart';
import 'package:arzo_real_estate/features/tours/booking_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  late AppStore store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    store = AppStore(prefs);
  });

  test(
    'session, profile, preferences and favorite survive recreation',
    () async {
      await store.signIn(userName: 'Alex Lee', userEmail: 'alex@example.com');
      await store.toggleSaved('terracota');
      await store.setDark(true);
      await store.setNotifications(false);
      await store.setLocation('Santa Monica, California');
      await store.updateProfile(
        'Alex Wang',
        'wang@example.com',
        usePhoto: false,
      );
      final restored = AppStore(prefs);
      expect(restored.signedIn, isTrue);
      expect(restored.onboarded, isTrue);
      expect(restored.saved, {'terracota'});
      expect(restored.name, 'Alex Wang');
      expect(restored.email, 'wang@example.com');
      expect(restored.location, 'Santa Monica, California');
      expect(restored.dark, isTrue);
      expect(restored.usePhoto, isFalse);
      expect(restored.notifications, isFalse);
      await restored.signOut();
      expect(AppStore(prefs).signedIn, isFalse);
      expect(AppStore(prefs).saved, {'terracota'});
    },
  );
  test(
    'rapid writes preserve the final snapshot and toggle removes a favorite',
    () async {
      final writes = [
        store.toggleSaved('terracota'),
        store.toggleSaved('scandina'),
        store.toggleSaved('terracota'),
      ];
      await Future.wait(writes);
      expect(AppStore(prefs).saved, {'scandina'});
    },
  );
  test('search handles case, whitespace, owner and type together', () {
    expect(store.search('  TERRACOTA  ').single.id, 'terracota');
    expect(store.search('Angela', category: 'Apartment').map((p) => p.id), [
      'eso',
    ]);
    expect(store.search('', category: 'House').length, 3);
    expect(store.search('not a property'), isEmpty);
  });
  test(
    'booking prevents conflicts, persists cancellation and frees a slot',
    () async {
      final date = DateTime(2027, 2, 10);
      final first = Tour(
        id: 'one',
        propertyId: 'terracota',
        video: false,
        date: date,
        time: '11:00 AM',
      );
      final conflict = Tour(
        id: 'two',
        propertyId: 'eso',
        video: true,
        date: date,
        time: '11:00 AM',
      );
      expect(await store.book(first), isTrue);
      expect(await store.book(conflict), isFalse);
      expect(AppStore(prefs).tours.single.property.name, 'Terracota House');
      await store.cancelTour('one');
      expect(AppStore(prefs).tours.single.status, 'Cancelled');
      expect(await store.book(conflict), isTrue);
      expect(AppStore(prefs).tours.first.video, isTrue);
    },
  );
  test(
    'messages trim whitespace, reject empty input and keep conversations apart',
    () async {
      await store.send('Angela Wani', '   ');
      expect(store.messages, isEmpty);
      await store.send('Angela Wani', '  Can I visit?  ');
      await store.send('William Smith', 'Hello');
      final restored = AppStore(prefs);
      expect(restored.messages['Angela Wani']!.single.text, 'Can I visit?');
      expect(restored.messages['William Smith']!.single.text, 'Hello');
    },
  );
  test('invalid JSON does not prevent startup', () async {
    await prefs.setString(AppStore.storageKey, '{broken');
    expect(AppStore(prefs).signedIn, isFalse);
  });
  test('time validation handles noon, past times and future dates', () {
    final now = DateTime(2026, 10, 24, 11, 30);
    final today = DateTime(2026, 10, 24);
    expect(isFutureSlot(today, '11:00 AM', now), isFalse);
    expect(isFutureSlot(today, '12:00 PM', now), isTrue);
    expect(isFutureSlot(today, '1:00 PM', now), isTrue);
    expect(
      isFutureSlot(today.add(const Duration(days: 1)), '9:00 AM', now),
      isTrue,
    );
  });
}
