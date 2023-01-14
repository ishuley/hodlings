import 'package:flutter/material.dart';

class ThemeChoiceDropdown extends StatefulWidget {
  final ValueChanged<String> onThemeChangedCallback;
  final String currentThemeDescription;

  const ThemeChoiceDropdown({
    super.key,
    required this.onThemeChangedCallback,
    required this.currentThemeDescription,
  });

  @override
  State<ThemeChoiceDropdown> createState() => _ThemeChoiceDropdownState();
}

class _ThemeChoiceDropdownState extends State<ThemeChoiceDropdown> {
  late String currentThemeChoice;

  @override
  Widget build(BuildContext context) {
    currentThemeChoice = widget.currentThemeDescription;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: Theme.of(context).primaryColor,
          onChanged: ((String? selectedTheme) {
            currentThemeChoice = selectedTheme!;
            widget.onThemeChangedCallback(currentThemeChoice);
          }),
          value: currentThemeChoice,
          items: const ['System theme', 'Dark theme', 'Light theme']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
