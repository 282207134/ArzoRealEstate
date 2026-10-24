import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const blue = Color(0xFF1E58F1);
const aqua = Color(0xFF08D9DF);
const mint = Color(0xFFE6FDFD);
const ink = Color(0xFF27364E);
const muted = Color(0xFF8391A7);

ThemeData arzoTheme(bool dark) {
  final scheme = ColorScheme.fromSeed(
    seedColor: blue,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: dark ? const Color(0xFF8AACFF) : blue,
    onPrimary: Colors.white,
    surface: dark ? const Color(0xFF152238) : Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: scheme.surface,
    textTheme: ThemeData(brightness: scheme.brightness).textTheme.apply(
      fontFamily: 'Manrope',
      bodyColor: dark ? Colors.white : ink,
      displayColor: dark ? Colors.white : ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      elevation: 0,
      systemOverlayStyle: dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerColor: dark ? const Color(0xFF2A3A51) : const Color(0xFFE9ECF2),
    inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: blue),
  );
}

extension ArzoColors on BuildContext {
  Color get accent => isDark ? const Color(0xFF8AACFF) : blue;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get paper => Theme.of(this).colorScheme.surface;
  Color get header => isDark ? const Color(0xFF1B3547) : mint;
  Color get textColor => isDark ? const Color(0xFFF4F7FC) : ink;
  Color get line => Theme.of(this).dividerColor;
  Color get soft => isDark ? const Color(0xFF203149) : const Color(0xFFF7F9FC);
}

TextStyle titleStyle([double size = 24]) => TextStyle(
  fontSize: size,
  fontWeight: FontWeight.w700,
  height: 1.35,
  letterSpacing: -0.5,
);
const bodyStyle = TextStyle(fontSize: 14, height: 1.75);
const hintStyle = TextStyle(fontSize: 12, color: muted, height: 1.6);
