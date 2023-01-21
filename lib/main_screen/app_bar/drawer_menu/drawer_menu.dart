import 'package:flutter/material.dart';
import 'package:hodlings/main_screen/app_bar/drawer_menu/theme_choice_dropdown.dart';
import 'refresh_asset_lists_button.dart';

class DrawerMenu extends StatelessWidget {
  final ValueChanged<String> onThemeChangedCallback;
  final String currentThemeDescription;

  const DrawerMenu({
    super.key,
    required this.onThemeChangedCallback,
    required this.currentThemeDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 0, 10),
            child: Text(
              'Theme:',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          ThemeChoiceDropdown(
            onThemeChangedCallback: onThemeChangedCallback,
            currentThemeDescription: currentThemeDescription,
          ),
          const Divider(
            height: 20,
          ),
          Row(
            children: const [
              RefreshAssetListsButton(),
              Spacer(),
              RefreshAssetHelpIcon(),
            ],
          ),
          const Divider(
            height: 10,
          ),
          // New drawer items go on this line
        ],
      ),
    );
  }
}
