import 'package:flutter/material.dart';

var lightThemeData = ThemeData.light().copyWith(
    useMaterial3: true,
    colorScheme: kColorScheme,
    elevatedButtonTheme: kElevatedButtonThemeData);

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 116, 192, 252),
);

var kElevatedButtonThemeData = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
  backgroundColor: kColorScheme.primaryContainer,
  elevation: 0,
  shadowColor: Colors.transparent,
));
