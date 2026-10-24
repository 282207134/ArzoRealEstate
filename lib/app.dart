import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'data/app_store.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/home/shell_screen.dart';

class ArzoApp extends StatelessWidget {
  const ArzoApp({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => AppScope(
    store: store,
    child: AnimatedBuilder(
      animation: store,
      builder: (context, _) => MaterialApp(
        title: 'Arzo',
        debugShowCheckedModeBanner: false,
        theme: arzoTheme(false),
        darkTheme: arzoTheme(true),
        themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: store.dark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: store.dark
                ? Brightness.dark
                : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: store.dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: child!,
        ),
        home: !store.onboarded
            ? const OnboardingScreen()
            : store.signedIn
            ? const ShellScreen()
            : const AuthScreen(),
      ),
    ),
  );
}
