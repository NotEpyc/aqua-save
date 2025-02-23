import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color.fromARGB(255, 25, 149, 147),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF6EAEE7),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFCFDF6),
  onBackground: Color(0xFF1A1C18),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
  surface: Color(0xFFF9FAF3),
  onSurface: Color(0xFF1A1C18),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF416FDF),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF6EAEE7),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFCFDF6),
  onBackground: Color(0xFF1A1C18),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
  surface: Color(0xFFF9FAF3),
  onSurface: Color(0xFF1A1C18),
);

final lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    labelStyle: TextStyle(color: lightColorScheme.primary),
    hintStyle: const TextStyle(color: Colors.black26),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black12),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black12),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightColorScheme.primary),
      borderRadius: BorderRadius.circular(10),
    ),
    
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    titleMedium: TextStyle(color: lightColorScheme.primary),
  ),
);

final darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[800],
    labelStyle: TextStyle(color: darkColorScheme.primary),
    hintStyle: const TextStyle(color: Colors.grey),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[700]!),
      borderRadius: BorderRadius.circular(10),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[600]!),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: darkColorScheme.primary),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: darkColorScheme.primary),
  ),
);
