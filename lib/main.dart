import 'package:flutter/material.dart';
import 'package:hodlings/api_service/api_service.dart';
import 'package:hodlings/main_screen/asset.dart';
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

// 1) Add the ability to sort by specific AssetCard elements like total, market
// cap, or alphabetically by ticker. Default it to total. Persist chosen sort
// order.
// 2) "Add to existing entry, or create new?"
// 3) Add attributions to CoinGecko and IEX Cloud.
// 4) Finish blockchain based address lookup.
// 5) Add ability to scan an address for select platforms and add a card or
// update a card for everything it finds
// 6) Add a selection of different vsCurrencies (if not the capability to convert and use any)
// 7) Add daily volume and % change. Give user option for displayed % change
// time frame. Persist it.
// 8) Add option to toggle whether market cap is described in words or numbers. Persist it.
// 9) Add support for different vs currencies, and the necessary conversions.
// as well as customized lists of preferred vs currencies that can be toggled
// through by pushing the net worth button.
// 10) Add the ability to back up AssetCard list to the cloud and restore by
// logging into firebase through SSO.
// 11) Add price alerts
// 12) Add ability to secure the app locally, using a pin or biometric login
// 13) Add a chart to each AssetCard based one the chosen % change time interval.
// Provide option to toggle chart on or off, add to settings, persist it.
// 14) Add the ability to back up settings to the cloud (which should be
// persistent already).
// 15) Add API support for exchanges and brokers where possible.
// 16) Add support for NFTs and scrape GameStops marketplace to support it,
// if necessary and permissible.
// 17) Add precious metal support.
// 18) Add more themes

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
    final String? storedTheme = prefs.getString(
      'lastTheme',
    );
    if (storedTheme != null) {
      setTheme(
        storedTheme,
      );
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

    await prefs.setString(
      'lastTheme',
      currentThemeDescription,
    );
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
    WidgetsBinding.instance.addObserver(
      this,
    );
  }

  @override
  void dispose() {
    saveAssetCardListState();
    WidgetsBinding.instance.removeObserver(
      this,
    );
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    super.didChangeAppLifecycleState(
      state,
    );
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
    await AssetCardListStorage().writeAssetCardsData(
      assetCardsList,
    );
  }

  void refreshNetWorth() {
    netWorth = 0;
    for (AssetCard assetCard in assetCardsList) {
      incrementNetWorth(
        assetCard.totalValue,
      );
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
        incrementNetWorth(
          newAssetCard.totalValue,
        );
        addToAssetList(newAssetCard);
      });
      saveAssetCardListState();
    }
  }

  void incrementNetWorth(
    double incrementAmount,
  ) {
    netWorth = netWorth + incrementAmount;
  }

  void decrementNetWorth(
    double decrementAmount,
  ) {
    netWorth = netWorth - decrementAmount;
  }

  void addToAssetList(AssetCard? newAssetCard) {
    assetCardsList.add(
      newAssetCard!,
    );
  }

  void deleteAssetCard(int index) {
    setState(() {
      decrementNetWorth(
        assetCardsList[index].totalValue,
      );
      assetCardsList.removeAt(
        index,
      );
    });
  }

  void editQuantity(int index, double newQty) async {
    double difference = newQty - assetCardsList[index].asset.quantity;
    setState(() {
      incrementNetWorth(
        difference * assetCardsList[index].price,
      );
      assetCardsList[index].asset.quantity += difference;
      assetCardsList[index].asset.dataSourceField =
          assetCardsList[index].asset.quantity.toString();
    });
    saveAssetCardListState();
  }

  Future<void> refreshAssetCards() async {
    /// Crypto assets refreshed seperately because CoinGecko lets us save on
    /// API calls by getting all the updated data with one call, whereas the
    /// other APIs do not.
    List<AssetCard> newAssetCardsList = await getRefreshedCryptoCards();
    newAssetCardsList.addAll(await addNonCryptoRefreshedAssetCardsToList());
    setState(() {
      assetCardsList = newAssetCardsList;
      refreshNetWorth();
    });
  }

  Future<List<AssetCard>> addNonCryptoRefreshedAssetCardsToList() async {
    List<AssetCard> newAssetCardsList = [];
    for (AssetCard card in assetCardsList) {
      if (card.asset.assetType != AssetType.crypto) {
        double newPrice = await card.asset.getPrice(
          vsTicker: vsTicker,
        );
        String newMarketCapString = await card.asset.getMarketCapString(
          vsTicker: vsTicker,
        );

        if (newPrice == 0) {
          newPrice = card.price;
        }
        newAssetCardsList.add(
          await refreshAnAssetCard(
            card.asset,
            newPrice,
            newMarketCapString,
          ),
        );
      }
    }
    return newAssetCardsList;
  }

  Future<List<AssetCard>> getRefreshedCryptoCards() async {
    List<AssetCard> cryptoCards = createListOfOnlyCryptoAssetCards();
    List<String> cryptoIdList = extractCryptoIdList(cryptoCards);
    Map<String, dynamic> cryptoData =
        await CryptoAPI().getData(ids: cryptoIdList, vsTickers: [vsTicker]);

    List<AssetCard> newAssetCardsList = await extractNewCryptoListsFromData(
      cryptoData,
      cryptoIdList,
    );
    return newAssetCardsList;
  }

  Future<List<AssetCard>> extractNewCryptoListsFromData(
    Map<String, dynamic> cryptoData,
    List<String> cryptoIdList,
  ) async {
    List<AssetCard> newAssetCardsList = [];
    String lowerCaseVsTicker = vsTicker.toLowerCase();
    if (cryptoData.isNotEmpty) {
      for (String cryptoId in cryptoIdList) {
        for (AssetCard assetCard in assetCardsList) {
          if (cryptoId == assetCard.asset.assetId) {
            double newPrice = assetCard.price;
            String newMarketCapString = assetCard.marketCapString;
            if (cryptoData[cryptoId][lowerCaseVsTicker] != null &&
                cryptoData[cryptoId][lowerCaseVsTicker] != 0) {
              newPrice = cryptoData[cryptoId][lowerCaseVsTicker];
            }
            if (cryptoData[cryptoId]['${lowerCaseVsTicker}_market_cap'] !=
                    null &&
                cryptoData[cryptoId][lowerCaseVsTicker] != 0) {
              double newMarketCap =
                  cryptoData[cryptoId]['${lowerCaseVsTicker}_market_cap'];
              newMarketCapString =
                  assetCard.asset.formatMarketCap(newMarketCap);
              newMarketCapString =
                  'Market Cap: $newMarketCapString ${lowerCaseVsTicker.toUpperCase()}';
            }
            newAssetCardsList.add(
              await refreshAnAssetCard(
                assetCard.asset,
                newPrice,
                newMarketCapString,
              ),
            );
          }
        }
      }
    }
    return newAssetCardsList;
  }

  List<AssetCard> createListOfOnlyCryptoAssetCards() {
    List<AssetCard> cryptoCards = [];

    for (AssetCard card in assetCardsList) {
      if (card.asset.assetType == AssetType.crypto) {
        cryptoCards.add(card);
      }
    }
    return cryptoCards;
  }

  List<String> extractCryptoIdList(List<AssetCard> cryptoCards) {
    List<String> cryptoIdList = [];
    for (AssetCard cryptoCard in cryptoCards) {
      cryptoIdList.add(cryptoCard.asset.assetId);
    }
    return cryptoIdList;
  }

  Future<AssetCard> refreshAnAssetCard(
    Asset asset,
    double newPrice,
    String marketCapString,
  ) async {
    return AssetCard(
      key: UniqueKey(),
      asset: asset,
      vsTicker: vsTicker,
      price: newPrice,
      marketCapString: marketCapString,
    );
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
              child: AssetCardDisplay(
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

  const RefreshAppBarIcon({
    super.key,
    required this.onRefreshedCallback,
  });

  @override
  State<RefreshAppBarIcon> createState() => _RefreshAppBarIconState();
}

class _RefreshAppBarIconState extends State<RefreshAppBarIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        12,
      ),
      child: InkWell(
        onTap: () => widget.onRefreshedCallback,
        splashColor: Colors.purple,
        child: const Icon(
          Icons.refresh_outlined,
        ),
      ),
    );
  }
}

class SortAppBarIcon extends StatefulWidget {
  const SortAppBarIcon({
    super.key,
  });

  @override
  State<SortAppBarIcon> createState() => _SortAppBarIconState();
}

enum SortType { totalValue, marketCap, price, quantity, name }

class _SortAppBarIconState extends State<SortAppBarIcon> {
  // TODO persist sortSelection and grab it on initialization
  SortType sortSelection = SortType.totalValue;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (SortType newSelection) {
        setState(() {
          sortSelection = newSelection;
        });
      },
      splashRadius: 22,
      position: PopupMenuPosition.under,
      initialValue: sortSelection,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
        const PopupMenuItem<SortType>(
          value: SortType.totalValue,
          child: Text('Value'),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.marketCap,
          child: Text('Market Cap'),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.price,
          child: Text('Price'),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.quantity,
          child: Text('Quantity'),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.name,
          child: Text('Name'),
        ),
      ],
      icon: const Icon(
        Icons.sort,
      ),
    );
  }
}
