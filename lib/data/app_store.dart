import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Local repository and observable state. Passwords are never persisted.
class AppStore extends ChangeNotifier {
  AppStore(this._preferences) {
    try {
      final raw = _preferences.getString(storageKey);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      onboarded = j['onboarded'] ?? false;
      signedIn = j['signedIn'] ?? false;
      name = j['name'] ?? name;
      email = j['email'] ?? email;
      location = j['location'] ?? location;
      dark = j['dark'] ?? false;
      usePhoto = j['usePhoto'] ?? true;
      notifications = j['notifications'] ?? true;
      saved.addAll(List<String>.from(j['saved'] ?? []));
      tours.addAll((j['tours'] as List? ?? []).map((v) => Tour.fromJson(v)));
      final chats = j['chats'] as Map<String, dynamic>? ?? {};
      for (final entry in chats.entries) {
        messages[entry.key] = (entry.value as List)
            .map((v) => ChatMessage.fromJson(v))
            .toList();
      }
    } on FormatException {
      // Invalid snapshots fall back to a local session.
    } on TypeError {
      // Older incompatible snapshots must not prevent startup.
    }
  }
  static const storageKey = 'arzo.v1';
  final SharedPreferences _preferences;
  Future<void> _writes = Future.value();
  bool onboarded = false,
      signedIn = false,
      dark = false,
      notifications = true,
      usePhoto = true;
  String name = 'Dorothy Ann',
      email = 'dorothyann@gmail.com',
      location = 'Los Angeles, California';
  final Set<String> saved = {};
  final List<Tour> tours = [];
  final Map<String, List<ChatMessage>> messages = {};

  Future<void> _commit() {
    final snapshot = jsonEncode({
      'onboarded': onboarded,
      'signedIn': signedIn,
      'name': name,
      'email': email,
      'location': location,
      'dark': dark,
      'notifications': notifications,
      'usePhoto': usePhoto,
      'saved': saved.toList(),
      'tours': tours.map((v) => v.toJson()).toList(),
      'chats': messages.map(
        (k, v) => MapEntry(k, v.map((m) => m.toJson()).toList()),
      ),
    });
    notifyListeners();
    _writes = _writes.then((_) async {
      await _preferences.setString(storageKey, snapshot);
    });
    return _writes;
  }

  Future<void> finishOnboarding() {
    onboarded = true;
    return _commit();
  }

  Future<void> signIn({String? userName, String? userEmail}) {
    onboarded = signedIn = true;
    if (userName != null) name = userName.trim();
    if (userEmail != null) email = userEmail.trim();
    return _commit();
  }

  Future<void> signOut() {
    signedIn = false;
    return _commit();
  }

  Future<void> toggleSaved(String id) {
    saved.contains(id) ? saved.remove(id) : saved.add(id);
    return _commit();
  }

  Future<void> updateProfile(
    String nextName,
    String nextEmail, {
    bool? usePhoto,
  }) {
    name = nextName.trim();
    email = nextEmail.trim();
    if (usePhoto != null) this.usePhoto = usePhoto;
    return _commit();
  }

  Future<void> setLocation(String value) {
    location = value;
    return _commit();
  }

  Future<void> setDark(bool value) {
    dark = value;
    return _commit();
  }

  Future<void> setNotifications(bool value) {
    notifications = value;
    return _commit();
  }

  List<Property> search(String query, {String category = 'All'}) {
    final q = query.trim().toLowerCase();
    return properties
        .where(
          (p) =>
              (category == 'All' || p.type == category) &&
              '${p.name} ${p.city} ${p.owner}'.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<bool> book(Tour tour) async {
    if (tours.any(
      (t) =>
          t.status != 'Cancelled' && t.date == tour.date && t.time == tour.time,
    )) {
      return false;
    }
    tours.insert(0, tour);
    await _commit();
    return true;
  }

  Future<void> cancelTour(String id) {
    final index = tours.indexWhere((t) => t.id == id);
    if (index >= 0) tours[index] = tours[index].cancelled();
    return _commit();
  }

  Future<void> send(String owner, String text) {
    if (text.trim().isEmpty) return Future.value();
    messages.putIfAbsent(owner, () => []).add(ChatMessage(text.trim()));
    return _commit();
  }
}

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);
  static AppStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
