import 'package:flutter/material.dart';
import 'package:hodlings/main_screen/drawer_menu/drawer_menu.dart';
import 'package:hodlings/main_screen/add_new_asset_button.dart';
import 'package:hodlings/main_screen/asset_card.dart';
import 'package:hodlings/main_screen/asset_card_display.dart';
import 'package:hodlings/main_screen/net_worth_button.dart';
import 'package:hodlings/persistence/asset_card_list_storage.dart';
import 'package:hodlings/themes.dart';
import 'add_new_asset_screen/add_new_asset_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO LIST:

// 7) Add the ability to sort by specific AssetCard elements like total, market
// cap, or alphabetically by ticker. Default it to total. Persist chosen sort
// order.
// 7.5) Add attributions to CoinGecko and IEX Cloud.
// 9) Finish blockchain based address lookup.
// 9.5) Add ability to scan an address for select platforms and add a card or
// update a card for everything it finds
// 9.75) Add a selection of different vsCurrencies (if not the capability to convert and use any)
// 10) Add daily volume and % change. Give user option for displayed % change
// time frame. Persist it.RefreshAssetListsButton
// 10.5) Add option to toggle whether market cap is described in words or numbers. Persist it.
// 11) Add support for different vs currencies, and the necessary conversions.
// as well as customized lists of preferred vs currencies that can be toggled
// through by pushing the net worth button.
// 12) Add the ability to back up AssetCard list to the cloud and restore by
// logging into firebase through SSO.
// 12.5 Add ability to secure the app locally, using a pin or biometric login
// 13) Add a chart to each AssetCard based one the chosen % change time interval.
// Provide option to toggle chart on or off, add to settings, persist it.
// 14) Add the ability to back up settings to the cloud (which should be
// persistent already).
// 15) Add API support for exchanges and brokers where possible.
// 16) Add support for NFTs and scrape GameStops marketplace to support it,
// if necessary and permissible.
// 18) Add precious metal support.
// ## Add more themes

void main() => runApp(const HODLings());

class HODLings extends StatefulWidget {
  const HODLings({super.key});

  @override
  State<HODLings> createState() => _HODLingsState();
}

class _HODLingsState extends State<HODLings> {
  ThemeMode currentTheme = ThemeMode.system;
  String currentThemeDescription = 'System theme';

  @override
  void initState() {
    super.initState();
    initTheme();
  }

  Future<void> initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedTheme = prefs.getString('lastTheme');
    if (storedTheme != null) {
      setTheme(storedTheme);
    }
  }

  void setTheme(String newTheme) {
    setState(() {
      currentTheme = getThemeFromChoice(newTheme);
      currentThemeDescription = newTheme;
    });
  }

  void onThemeChanged(String chosenTheme) async {
    setTheme(chosenTheme);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastTheme', currentThemeDescription);
  }

  ThemeMode getThemeFromChoice(String themeChoice) {
    switch (themeChoice) {
      case 'Dark theme':
        return ThemeMode.dark;
      case 'Light theme':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => MainScreen(
              onThemeChangedCallback: onThemeChanged,
              currentThemeDescription: currentThemeDescription,
            ),
      },
      title: 'HODLings',
      themeMode: currentTheme,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
    );
  }
}

class MainScreen extends StatefulWidget {
  final ValueChanged<String> onThemeChangedCallback;
  final String currentThemeDescription;

  const MainScreen({
    super.key,
    required this.onThemeChangedCallback,
    required this.currentThemeDescription,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  double netWorth = 0;
  String vsTicker = 'USD';
  List<AssetCard> assetCardsList = [];

  @override
  void initState() {
    super.initState();
    readAssetCardListState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    saveAssetCardListState();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      return;
    }
    final appHasBeenClosed = state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive;

    if (appHasBeenClosed) {
      saveAssetCardListState();
    }
  }

  void saveAssetCardListState() async {
    await AssetCardListStorage().writeAssetCardsData(assetCardsList);
  }

  void setNetWorthFromZero() {
    for (AssetCard assetCard in assetCardsList) {
      incrementNetWorth(assetCard.totalValue);
    }
  }

  void readAssetCardListState() async {
    List<AssetCard> newAssetCardList =
        await AssetCardListStorage().readAssetCardsData();
    setState(() {
      assetCardsList = newAssetCardList;
      refreshNetWorth();
    });
  }

  void onNetWorthButtonPressed() {
    setState(() {
      // TODO Make this listener update the vsTicker appropriately to the next available vsCurrency when pressed.
    });
  }

  Future<void> addNewAssetScreen() async {
    final AssetCard? newAssetCard = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewAssetScreen(),
      ),
    );
    if (newAssetCard != null) {
      setState(() {
        incrementNetWorth(newAssetCard.totalValue);
        addToAssetList(newAssetCard);
      });
      saveAssetCardListState();
    }
  }

  void incrementNetWorth(double incrementAmount) {
    netWorth = netWorth + incrementAmount;
  }

  void decrementNetWorth(double decrementAmount) {
    netWorth = netWorth - decrementAmount;
  }

  void addToAssetList(AssetCard? newAssetCard) {
    assetCardsList.add(newAssetCard!);
  }

  void deleteAssetCard(int index) {
    setState(() {
      decrementNetWorth(assetCardsList[index].totalValue);
      assetCardsList.removeAt(index);
    });
  }

  void editQuantity(int index, double newQty) async {
    double difference = newQty - assetCardsList[index].asset.quantity;
    setState(() {
      incrementNetWorth(difference * assetCardsList[index].price);
      assetCardsList[index].asset.quantity += difference;
      assetCardsList[index].asset.dataSourceField =
          assetCardsList[index].asset.quantity.toString();
    });
    saveAssetCardListState();
  }

  Future<void> refreshAssetCards() async {
    List<AssetCard> newAssetCardsList = [];
    for (AssetCard card in assetCardsList) {
      AssetCard refreshedAssetCard = AssetCard(
        key: UniqueKey(),
        asset: card.asset,
        vsTicker: vsTicker,
        price: await card.asset.getPrice(vsTicker: vsTicker),
        marketCapString:
            await card.asset.getMarketCapString(vsTicker: vsTicker),
      );
      newAssetCardsList.add(refreshedAssetCard);
    }
    setState(() {
      assetCardsList = newAssetCardsList;
      netWorth = 0;
      setNetWorthFromZero();
    });
  }

  void refreshNetWorth() {
    netWorth = 0;
    setNetWorthFromZero();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'HODLings',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        actions: [
          const SortAppBarIcon(),
          RefreshAppBarIcon(
            onRefreshedCallback: refreshAssetCards,
          ),
        ],
      ),
      drawer: DrawerMenu(
        onThemeChangedCallback: widget.onThemeChangedCallback,
        currentThemeDescription: widget.currentThemeDescription,
      ),
      body: Center(
        child: Column(
          children: [
            NetWorthButton(
              netWorth: NumberFormat('###,###,###,###,###,###', 'en_US')
                  .format(netWorth),
              vsTicker: vsTicker,
              onNetWorthClickCallback: onNetWorthButtonPressed,
            ),
            Expanded(
              child: AssetDisplay(
                key: UniqueKey(),
                assetList: assetCardsList,
                deleteAssetCardCallback: deleteAssetCard,
                editAssetCardQuantityCallback: editQuantity,
                onRefreshedCallback: refreshAssetCards,
              ),
            ),
            AddNewAssetButton(
              addNewAssetCallback: addNewAssetScreen,
            ),
          ],
        ),
      ),
    );
  }
}

class RefreshAppBarIcon extends StatefulWidget {
  final void Function() onRefreshedCallback;

  const RefreshAppBarIcon({super.key, required this.onRefreshedCallback});

  @override
  State<RefreshAppBarIcon> createState() => _RefreshAppBarIconState();
}

class _RefreshAppBarIconState extends State<RefreshAppBarIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
      child: GestureDetector(
        onTap: widget.onRefreshedCallback,
        child: const Icon(
          Icons.refresh,
        ),
      ),
    );
  }
}

class SortAppBarIcon extends StatefulWidget {
  const SortAppBarIcon({super.key});

  @override
  State<SortAppBarIcon> createState() => _SortAppBarIconState();
}

class _SortAppBarIconState extends State<SortAppBarIcon> {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.sort);
  }
}
