import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodlings/themes/theme_notifier.dart';

class ThemeChoiceDropdown extends ConsumerStatefulWidget {
  const ThemeChoiceDropdown({
    super.key,
  });

  @override
  ConsumerState<ThemeChoiceDropdown> createState() =>
      _ThemeChoiceDropdownState();
}

getStringFromThemeMode(ThemeMode themeMode) {
  switch (themeMode) {
    case ThemeMode.dark:
      return 'Dark theme';
    case ThemeMode.light:
      return 'Light theme';
    default:
      return 'System theme';
  }
}

class _ThemeChoiceDropdownState extends ConsumerState<ThemeChoiceDropdown> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).primaryColor,
        ),
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: Theme.of(
            context,
          ).primaryColor,
          onChanged: ((String? selectedTheme) {
            if (selectedTheme != null) {
              ref
                  .read(currentThemeNotifierProvider.notifier)
                  .changeTheme(selectedTheme);
            }
          }),
          value:
              getStringFromThemeMode(ref.watch(currentThemeNotifierProvider)),
          items: const [
            'System theme',
            'Dark theme',
            'Light theme',
          ].map<DropdownMenuItem<String>>(
            (
              String themeChoiceAsString,
            ) {
              return DropdownMenuItem<String>(
                value: themeChoiceAsString,
                child: Text(
                  themeChoiceAsString,
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
