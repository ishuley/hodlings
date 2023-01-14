import 'package:flutter/material.dart';
import 'package:hodlings/drawer_menu/refresh_asset_cards_button.dart';
import 'package:hodlings/drawer_menu/theme_choice_dropdown.dart';
import 'refresh_asset_lists_button.dart';

class DrawerMenu extends StatelessWidget {
  final ValueChanged<String> onThemeChangedCallback;
  final String currentThemeDescription;

  final VoidCallback onRefreshAssetCardsCallback;
  const DrawerMenu({
    super.key,
    required this.onThemeChangedCallback,
    required this.currentThemeDescription,
    required this.onRefreshAssetCardsCallback,
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
            children: [
              RefreshAssetCardsButton(
                onRefreshAssetCardsCallback: onRefreshAssetCardsCallback,
              ),
              const Spacer(),
            ],
          ),
          const Divider(
            height: 10,
          ),
          Row(
            children: const [
              RefreshAssetListsButton(),
              Spacer(),
              RefreshAssetHelpIcon(),
            ],
          ),
        ],
      ),
    );
  }
}
