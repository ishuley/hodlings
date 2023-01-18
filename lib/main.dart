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
      currentTheme = getThemeFromChoice(
        newTheme,
      );
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

  ThemeMode getThemeFromChoice(
    String themeChoice,
  ) {
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
  bool ascending = false;
  SortType sortType = SortType.totalValue;

  @override
  void initState() {
    super.initState();
    readAssetCardListState();
    WidgetsBinding.instance.addObserver(
      this,
    );
    initSortTypeFromPrefs();
    sortAssetCards();
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
      saveAssetCardsListState();
      saveSortType();
    }
  }

  @override
  void dispose() {
    saveAssetCardsListState();
    saveSortType();
    WidgetsBinding.instance.removeObserver(
      this,
    );
    super.dispose();
  }

  void saveSortType() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'lastSortType',
      getSortTypeStringFromEnum(),
    );
    await prefs.setBool('isAscending', ascending);
    print(getSortTypeStringFromEnum());
    print(ascending.toString());
    print('called');
  }

  String getSortTypeStringFromEnum() {
    switch (sortType) {
      case SortType.totalValue:
        return 'totalValue';
      case SortType.quantity:
        return 'quantity';
      case SortType.price:
        return 'price';
      case SortType.name:
        return 'name';
      case SortType.marketCap:
        return 'marketCap';
    }
  }

  Future<void> initSortTypeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sortTypeString = prefs.getString(
      'lastSortType',
    );
    final bool? isAscending = prefs.getBool(
      'isAscending',
    );
    if (sortTypeString != null) {
      sortType = getSortTypeFromString(sortTypeString);
    }
    if (isAscending != null) {
      ascending = isAscending;
    }
  }

  void readAssetCardListState() async {
    List<AssetCard> newAssetCardList =
        await AssetCardListStorage().readAssetCardsData();
    setState(() {
      assetCardsList = newAssetCardList;
      updateNetWorth();
    });
  }

  void updateNetWorth() {
    netWorth = 0;
    for (AssetCard assetCard in assetCardsList) {
      incrementNetWorth(
        assetCard.totalValue,
      );
    }
  }

  void saveAssetCardsListState() async {
    await AssetCardListStorage().writeAssetCardsData(
      assetCardsList,
    );
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
        addToAssetList(
          newAssetCard,
        );
      });
      saveAssetCardsListState();
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

  void addToAssetList(
    AssetCard? newAssetCard,
  ) {
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
    saveAssetCardsListState();
  }

  Future<void> refreshAssetCards() async {
    /// Crypto assets refreshed seperately because CoinGecko lets us save on
    /// API calls by getting all the updated data with one call, whereas the
    /// other APIs do not.
    List<AssetCard> newAssetCardsList = await getRefreshedCryptoCardList();
    newAssetCardsList.addAll(await getRefreshedNonCryptoAssetCardList());

    setState(() {
      assetCardsList = newAssetCardsList;
      updateNetWorth();
    });
    sortAssetCards();
  }

  Future<List<AssetCard>> getRefreshedNonCryptoAssetCardList() async {
    List<AssetCard> newAssetCardsList = [];
    double extendedHoursPrice = 0;
    for (AssetCard card in assetCardsList) {
      if (card.asset.assetType != AssetType.crypto) {
        double newPrice = await card.asset.getPrice(
          vsTicker: vsTicker,
        );
        String newMarketCapString = await card.asset.getMarketCapString(
          vsTicker: vsTicker,
        );
        if (card.asset.assetType == AssetType.stock) {
          Stock asset = card.asset as Stock;
          extendedHoursPrice = await asset.getExtendedHoursPrice();
        }

        if (newPrice == 0) {
          newPrice = card.price;
        }
        newAssetCardsList.add(
          await refreshAnAssetCard(
            asset: card.asset,
            newPrice: newPrice,
            newMarketCapString: newMarketCapString,
            extendedHoursPrice: extendedHoursPrice,
          ),
        );
      }
    }
    return newAssetCardsList;
  }

  Future<List<AssetCard>> getRefreshedCryptoCardList() async {
    List<AssetCard> cryptoCards = separateCryptoCardsListFromOldAssetCardList();
    List<String> cryptoIdList = extractCryptoIdList(cryptoCards);
    Map<String, dynamic> cryptoData = await CryptoAPI().getData(
      ids: cryptoIdList,
      vsTickers: [vsTicker],
    );

    List<AssetCard> newAssetCardsList = await extractNewCryptoCardListFromData(
      cryptoData,
      cryptoIdList,
    );
    return newAssetCardsList;
  }

  List<AssetCard> separateCryptoCardsListFromOldAssetCardList() {
    List<AssetCard> cryptoCards = [];

    for (AssetCard card in assetCardsList) {
      if (card.asset.assetType == AssetType.crypto) {
        cryptoCards.add(
          card,
        );
      }
    }
    return cryptoCards;
  }

  List<String> extractCryptoIdList(List<AssetCard> cryptoCards) {
    List<String> cryptoIdList = [];
    for (AssetCard cryptoCard in cryptoCards) {
      cryptoIdList.add(
        cryptoCard.asset.assetId,
      );
    }
    return cryptoIdList;
  }

  Future<List<AssetCard>> extractNewCryptoCardListFromData(
    Map<String, dynamic> cryptoData,
    List<String> cryptoIdList,
  ) async {
    List<AssetCard> newAssetCardsList = [];
    String lowerCaseVsTicker = vsTicker.toLowerCase();
    if (cryptoData.isNotEmpty) {
      for (String cryptoId in cryptoIdList) {
        for (AssetCard assetCard in assetCardsList) {
          if (cryptoId == assetCard.asset.assetId) {
            double newPrice = extractNewPriceFromCryptoData(
              assetCard,
              cryptoData,
              cryptoId,
              lowerCaseVsTicker,
            );
            String newMarketCapString = extractNewMktCapStringFromCryptoData(
              assetCard,
              cryptoData,
              cryptoId,
              lowerCaseVsTicker,
            );
            newAssetCardsList.add(
              await refreshAnAssetCard(
                asset: assetCard.asset,
                newPrice: newPrice,
                newMarketCapString: newMarketCapString,
              ),
            );
          }
        }
      }
    }
    return newAssetCardsList;
  }

  double extractNewPriceFromCryptoData(
    AssetCard assetCard,
    Map<String, dynamic> cryptoData,
    String cryptoId,
    String lowerCaseVsTicker,
  ) {
    double newPrice = assetCard.price;
    if (cryptoData[cryptoId][lowerCaseVsTicker] != null &&
        cryptoData[cryptoId][lowerCaseVsTicker] != 0) {
      newPrice = cryptoData[cryptoId][lowerCaseVsTicker];
    }
    return newPrice;
  }

  String extractNewMktCapStringFromCryptoData(
    AssetCard assetCard,
    Map<String, dynamic> cryptoData,
    String cryptoId,
    String lowerCaseVsTicker,
  ) {
    String newMarketCapString = assetCard.marketCapString;
    if (cryptoData[cryptoId]['${lowerCaseVsTicker}_market_cap'] != null &&
        cryptoData[cryptoId][lowerCaseVsTicker] != 0) {
      double newMarketCap =
          cryptoData[cryptoId]['${lowerCaseVsTicker}_market_cap'];
      newMarketCapString = assetCard.asset.formatMarketCap(newMarketCap);
      newMarketCapString =
          'Market Cap: $newMarketCapString ${lowerCaseVsTicker.toUpperCase()}';
    }
    return newMarketCapString;
  }

  Future<AssetCard> refreshAnAssetCard({
    required Asset asset,
    required double newPrice,
    required String newMarketCapString,
    double extendedHoursPrice = 0,
  }) async {
    return AssetCard(
      key: UniqueKey(),
      asset: asset,
      vsTicker: vsTicker,
      price: newPrice,
      marketCapString: newMarketCapString,
      extendedHoursPrice: extendedHoursPrice,
    );
  }

  void sortAssetCards() {
    setState(() {
      switch (sortType) {
        case SortType.totalValue:
          if (ascending == true) {
            assetCardsList
                .sort(((a, b) => a.totalValue.compareTo(b.totalValue)));
          }
          if (ascending == false) {
            assetCardsList
                .sort(((b, a) => a.totalValue.compareTo(b.totalValue)));
          }
          break;
        case SortType.marketCap:
          if (ascending == true) {
            assetCardsList.sort(
              ((a, b) => a.asset.marketCap.compareTo(b.asset.marketCap)),
            );
          }
          if (ascending == false) {
            assetCardsList.sort(
              ((b, a) => a.asset.marketCap.compareTo(b.asset.marketCap)),
            );
          }
          break;
        case SortType.price:
          if (ascending == true) {
            assetCardsList.sort(((a, b) => a.price.compareTo(b.price)));
          }
          if (ascending == false) {
            assetCardsList.sort(((b, a) => a.price.compareTo(b.price)));
          }
          break;
        case SortType.quantity:
          if (ascending == true) {
            assetCardsList
                .sort(((a, b) => a.asset.quantity.compareTo(b.asset.quantity)));
          }
          if (ascending == false) {
            assetCardsList
                .sort(((b, a) => a.asset.quantity.compareTo(b.asset.quantity)));
          }
          break;
        case SortType.name:
          if (ascending == true) {
            assetCardsList
                .sort(((b, a) => a.asset.name.compareTo(b.asset.name)));
          }
          if (ascending == false) {
            assetCardsList
                .sort(((a, b) => a.asset.name.compareTo(b.asset.name)));
          }
          break;
      }
    });
  }

  void setSortType(SortType newSortType) {
    setState(() {
      sortType = newSortType;
    });
    saveSortType();
  }

  void toggleSortDirectionAscending() {
    setState(
      () {
        ascending = !ascending;
      },
    );
  }

  SortType getSortTypeFromString(String sortTypeString) {
    switch (sortTypeString) {
      case 'totalValue':
        return SortType.totalValue;
      case 'marketCap':
        return SortType.marketCap;
      case 'price':
        return SortType.price;
      case 'quantity':
        return SortType.quantity;
      case 'name':
        return SortType.name;
    }
    throw ArgumentError(
      'invalid sort type read from prefs somehow, should not be happening',
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
          SortAppBarIcon(
            sortCallback: sortAssetCards,
            setSortTypeCallback: setSortType,
            currentSortType: sortType,
          ),
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
              netWorth: NumberFormat(
                '###,###,###,###,###,###',
                'en_US',
              ).format(
                netWorth,
              ),
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
        onTap: () => widget.onRefreshedCallback(),
        splashColor: Colors.purple,
        child: const Icon(
          Icons.refresh_outlined,
        ),
      ),
    );
  }
}

class SortAppBarIcon extends StatefulWidget {
  final void Function() sortCallback;
  final void Function(SortType) setSortTypeCallback;

  final SortType currentSortType;

  const SortAppBarIcon({
    super.key,
    required this.sortCallback,
    required this.setSortTypeCallback,
    required this.currentSortType,
  });

  @override
  State<SortAppBarIcon> createState() => _SortAppBarIconState();
}

enum SortType { totalValue, marketCap, price, quantity, name }

class _SortAppBarIconState extends State<SortAppBarIcon> {
  // TODO persist sortSelection and grab it on app's initialization

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (SortType newSelection) {
        setState(
          () {
            widget.setSortTypeCallback(newSelection);
            widget.sortCallback();
          },
        );
      },
      splashRadius: 22,
      position: PopupMenuPosition.under,
      initialValue: widget.currentSortType,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
        const PopupMenuItem<SortType>(
          value: SortType.totalValue,
          child: Text(
            'Total Value',
          ),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.marketCap,
          child: Text(
            'Market Cap',
          ),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.price,
          child: Text(
            'Price',
          ),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.quantity,
          child: Text(
            'Quantity',
          ),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.name,
          child: Text(
            'Name',
          ),
        ),
      ],
      icon: const Icon(
        Icons.sort,
      ),
    );
  }
}
