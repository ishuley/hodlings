import 'package:flutter/material.dart';
import 'package:hodlings/main_screen/app_bar/drawer_menu/theme_choice_dropdown.dart';
import 'refresh_asset_lists_button.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Drawer(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor,
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              10,
              20,
              0,
              10,
            ),
            child: Text(
              'Theme:',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const ThemeChoiceDropdown(),
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
