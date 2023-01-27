import 'package:flutter/material.dart';

/// Themes that describe the colors and stylings of visual elements that
/// compose the graphical interface through which the human interacts with the
///  app. Accessed through [Theme.of(context)]
class Themes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey[850],
    colorScheme: const ColorScheme.dark(),
    primaryColor: Colors.grey[850],
    appBarTheme: AppBarTheme(
      color: Colors.black12,
      titleTextStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.grey[300], size: 30),
    ),
    cardColor: Colors.grey.shade800,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.black26,
        ),
      ),
    ),

    /// toggleableActiveColor is for [AssetTypeSelection]
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 30,
    ),
    textTheme: const TextTheme(
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 24,
      ),
      labelSmall: TextStyle(
        color: Colors.white70,
        fontSize: 13,
      ),
    ),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade500,
    colorScheme: const ColorScheme.light(),
    primaryColor: Colors.grey.shade400,
    appBarTheme: AppBarTheme(
      color: Colors.green,
      titleTextStyle: TextStyle(
        color: Colors.grey[300],
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.grey[200], size: 30),
    ),
    cardColor: Colors.grey.shade400,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.grey[400],
        ),
      ),
    ),

    /// toggleableActiveColor is for [AssetTypeSelection]
    iconTheme: const IconThemeData(
      color: Colors.black,
      size: 30,
    ),
    textTheme: const TextTheme(
      labelLarge: TextStyle(
        color: Colors.black,
        fontSize: 24,
      ),
      labelSmall: TextStyle(
        color: Colors.black,
        fontSize: 12,
      ),
    ),
  );
}
