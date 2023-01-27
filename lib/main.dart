import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodlings/main_screen/app_bar/refresh_icon.dart';
import 'package:hodlings/main_screen/app_bar/sort_by_icon.dart';
import 'package:hodlings/main_screen/app_bar/drawer_menu/drawer_menu.dart';
import 'package:hodlings/main_screen/add_new_asset_button.dart';

import 'package:hodlings/main_screen/asset_display/asset_card_display.dart';
import 'package:hodlings/main_screen/asset_display/asset_card_list_notifier.dart';
import 'package:hodlings/main_screen/app_bar/sort_type_notifier.dart';
import 'package:hodlings/main_screen/net_worth_display/net_worth_button.dart';
import 'package:hodlings/themes/theme_notifier.dart';
import 'package:hodlings/themes/themes.dart';

void main() => runApp(const ProviderScope(child: HODLings()));

class HODLings extends ConsumerStatefulWidget {
  const HODLings({super.key});

  @override
  ConsumerState<HODLings> createState() => _HODLingsState();
}

class _HODLingsState extends ConsumerState<HODLings> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.read(currentThemeNotifierProvider.notifier).setLastThemeFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const MainScreen(),
      },
      title: 'HODLings',
      themeMode: ref.watch(currentThemeNotifierProvider),
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      this,
    );
    ref.read(sortTypeNotifierProvider.notifier).initSortTypeFromPrefs();
    ref.read(assetCardsListNotifierProvider.notifier).readAssetCardList();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(
      state,
    );
    if (state == AppLifecycleState.paused) {
      return;
    }
    final appHasBeenClosed = state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive;

    if (appHasBeenClosed) {
      await ref
          .read(assetCardsListNotifierProvider.notifier)
          .saveAssetCardsList();
    }
  }

  @override
  Future<void> dispose() async {
    await ref
        .read(assetCardsListNotifierProvider.notifier)
        .saveAssetCardsList();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(
          context,
        ).appBarTheme.backgroundColor,
        title: Text(
          'HODLings',
          style: Theme.of(
            context,
          ).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        iconTheme: Theme.of(
          context,
        ).appBarTheme.iconTheme,
        actions: const [
          SortAppBarIcon(),
          RefreshAppBarIcon(),
        ],
      ),
      drawer: const DrawerMenu(),
      body: Center(
        child: Column(
          children: [
            const NetWorthButton(),
            Expanded(
              child: AssetCardDisplay(
                key: UniqueKey(),
              ),
            ),
            const AddNewAssetButton(),
          ],
        ),
      ),
    );
  }
}
