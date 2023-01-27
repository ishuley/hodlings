import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final currentThemeNotifierProvider =
    StateNotifierProvider<CurrentThemeNotifier, ThemeMode>(
  (ref) => CurrentThemeNotifier(),
);

class CurrentThemeNotifier extends StateNotifier<ThemeMode> {
  CurrentThemeNotifier() : super(ThemeMode.dark);

  Future<SharedPreferences> getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  void changeTheme(String chosenThemeString) async {
    state = getThemeFromChoice(chosenThemeString);
    await persistCurrentTheme(chosenThemeString);
  }

  void setLastThemeFromPrefs() async {
    final SharedPreferences prefs = await getSharedPrefs();
    String? newState = prefs.getString('lastTheme');
    if (newState != null) {
      state = getThemeFromChoice(newState);
    }
  }

  Future<void> persistCurrentTheme(String chosenThemeString) async {
    final SharedPreferences prefs = await getSharedPrefs();

    await prefs.setString(
      'lastTheme',
      chosenThemeString,
    );
  }

  ThemeMode getThemeFromChoice(String choiceString) {
    switch (choiceString) {
      case 'Dark theme':
        return ThemeMode.dark;
      case 'Light theme':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}
