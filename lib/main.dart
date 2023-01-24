import 'package:flutter/material.dart';
import 'package:hodlings/api_service/api_service.dart';
import 'package:hodlings/main_screen/app_bar/refresh_icon.dart';
import 'package:hodlings/main_screen/app_bar/sort_by_icon.dart';
import 'package:hodlings/main_screen/asset.dart';
import 'package:hodlings/main_screen/app_bar/drawer_menu/drawer_menu.dart';
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
  ThemeMode _currentTheme = ThemeMode.system;
  String _currentThemeDescription = 'System theme';

  @override
  void initState() {
    super.initState();
    _initTheme();
  }

  Future<void> _initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedTheme = prefs.getString(
      'lastTheme',
    );
    if (storedTheme != null) {
      _setTheme(
        storedTheme,
      );
    }
  }

  void _setTheme(String newTheme) {
    setState(() {
      _currentTheme = _getThemeFromChoice(
        newTheme,
      );
      _currentThemeDescription = newTheme;
    });
  }

  void _onThemeChanged(String chosenTheme) async {
    _setTheme(chosenTheme);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'lastTheme',
      _currentThemeDescription,
    );
  }

  ThemeMode _getThemeFromChoice(
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
              onThemeChangedCallback: _onThemeChanged,
              currentThemeDescription: _currentThemeDescription,
            ),
      },
      title: 'HODLings',
      themeMode: _currentTheme,
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
  double _netWorth = 0;
  final String _vsTicker = 'USD';
  List<AssetCard> _assetCardsList = [];
  bool _ascending = false;
  SortType _sortType = SortType.totalValue;

  @override
  void initState() {
    super.initState();
    _readAssetCardListState();
    WidgetsBinding.instance.addObserver(
      this,
    );
    _initSortTypeFromPrefs();
    _sortAssetCards();
    _refreshAssetCards();
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
      _saveAssetCardsListState();
    }
  }

  @override
  void dispose() {
    _saveAssetCardsListState();
    WidgetsBinding.instance.removeObserver(
      this,
    );
    super.dispose();
  }

  void _saveSortType() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'lastSortType',
      _getSortTypeStringFromEnum(),
    );
    await prefs.setBool('isAscending', _ascending);
  }

  String _getSortTypeStringFromEnum() {
    switch (_sortType) {
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

  Future<void> _initSortTypeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sortTypeString = prefs.getString(
      'lastSortType',
    );
    final bool? isAscending = prefs.getBool(
      'isAscending',
    );
    if (sortTypeString != null) {
      _sortType = _getSortTypeFromString(sortTypeString);
    }
    if (isAscending != null) {
      _ascending = isAscending;
    }
  }

  void _readAssetCardListState() async {
    List<AssetCard> newAssetCardList =
        await AssetCardListStorage().readAssetCardsData();
    setState(() {
      _assetCardsList = newAssetCardList;
      _updateNetWorth();
    });
  }

  void _updateNetWorth() {
    _netWorth = 0;
    for (AssetCard assetCard in _assetCardsList) {
      _incrementNetWorth(
        assetCard.totalValue,
      );
    }
  }

  void _saveAssetCardsListState() async {
    await AssetCardListStorage().writeAssetCardsData(
      _assetCardsList,
    );
  }

  void _onNetWorthButtonPressed() {
    setState(() {
      // TODO Make this listener update the vsTicker appropriately to the next available vsCurrency when pressed.
    });
  }

  Future<void> _addNewAssetScreen() async {
    final AssetCard? newAssetCard = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewAssetScreen(),
      ),
    );
    if (newAssetCard != null) {
      setState(() {
        _incrementNetWorth(
          newAssetCard.totalValue,
        );
        _addToAssetList(
          newAssetCard,
        );
      });
      _sortAssetCards();
      _saveAssetCardsListState();
      _saveSortType();
    }
  }

  void _incrementNetWorth(
    double incrementAmount,
  ) {
    _netWorth = _netWorth + incrementAmount;
  }

  void _decrementNetWorth(
    double decrementAmount,
  ) {
    _netWorth = _netWorth - decrementAmount;
  }

  void _addToAssetList(
    AssetCard? newAssetCard,
  ) {
    _assetCardsList.add(
      newAssetCard!,
    );
  }

  void _deleteAssetCard(int index) {
    setState(() {
      _decrementNetWorth(
        _assetCardsList[index].totalValue,
      );
      _assetCardsList.removeAt(
        index,
      );
    });
  }

  void _editQuantity(int index, double newQty) async {
    double difference = newQty - _assetCardsList[index].asset.quantity;
    setState(() {
      _incrementNetWorth(
        difference * _assetCardsList[index].price,
      );
      _assetCardsList[index].asset.quantity += difference;
      _assetCardsList[index].asset.dataSourceField =
          _assetCardsList[index].asset.quantity.toString();
    });
    _saveAssetCardsListState();
  }

  Future<void> _refreshAssetCards() async {
    /// Crypto assets refreshed seperately because CoinGecko lets us save on
    /// API calls by getting all the updated data with one call, whereas the
    /// other APIs do not.
    List<AssetCard> newAssetCardsList = await _getRefreshedCryptoCardList();
    newAssetCardsList.addAll(await _getRefreshedNonCryptoAssetCardList());

    setState(() {
      _assetCardsList = newAssetCardsList;
      _updateNetWorth();
    });
    _sortAssetCards();
  }

  Future<List<AssetCard>> _getRefreshedNonCryptoAssetCardList() async {
    List<AssetCard> newAssetCardsList = [];
    // double extendedHoursPrice = 0;
    for (AssetCard card in _assetCardsList) {
      if (card.asset.assetType != AssetType.crypto) {
        double newPrice = await card.asset.getPrice(
          vsTicker: _vsTicker,
        );
        String newMarketCapString = await card.asset.getMarketCapString(
          vsTicker: _vsTicker,
        );
        // if (card.asset.assetType == AssetType.stock) {
        //   Stock asset = card.asset as Stock;
        //   extendedHoursPrice = await asset.getExtendedHoursPrice();
        // }

        if (newPrice == 0) {
          newPrice = card.price;
        }
        newAssetCardsList.add(
          await _refreshAnAssetCard(
            asset: card.asset,
            newPrice: newPrice,
            newMarketCapString: newMarketCapString,
            // extendedHoursPrice: extendedHoursPrice,
          ),
        );
      }
    }
    return newAssetCardsList;
  }

  Future<List<AssetCard>> _getRefreshedCryptoCardList() async {
    List<AssetCard> cryptoCards =
        _separateCryptoCardsListFromOldAssetCardList();
    List<String> cryptoIdList = _extractCryptoIdList(cryptoCards);
    Map<String, dynamic> cryptoData = await CryptoAPI().getData(
      ids: cryptoIdList,
      vsTickers: [_vsTicker],
    );

    List<AssetCard> newAssetCardsList = await _extractNewCryptoCardListFromData(
      cryptoData,
      cryptoIdList,
    );
    return newAssetCardsList;
  }

  List<AssetCard> _separateCryptoCardsListFromOldAssetCardList() {
    List<AssetCard> cryptoCards = [];

    for (AssetCard card in _assetCardsList) {
      if (card.asset.assetType == AssetType.crypto) {
        cryptoCards.add(
          card,
        );
      }
    }
    return cryptoCards;
  }

  List<String> _extractCryptoIdList(List<AssetCard> cryptoCards) {
    List<String> cryptoIdList = [];
    for (AssetCard cryptoCard in cryptoCards) {
      cryptoIdList.add(
        cryptoCard.asset.assetId,
      );
    }
    return cryptoIdList;
  }

  Future<List<AssetCard>> _extractNewCryptoCardListFromData(
    Map<String, dynamic> cryptoData,
    List<String> cryptoIdList,
  ) async {
    List<AssetCard> newAssetCardsList = [];
    String lowerCaseVsTicker = _vsTicker.toLowerCase();
    if (cryptoData.isNotEmpty) {
      for (String cryptoId in cryptoIdList) {
        for (AssetCard assetCard in _assetCardsList) {
          if (cryptoId == assetCard.asset.assetId) {
            // TODO create a constructor teardown for these
            double newPrice = _extractNewPriceFromCryptoData(
              assetCard,
              cryptoData,
              cryptoId,
              lowerCaseVsTicker,
            );
            String newMarketCapString = _extractNewMktCapStringFromCryptoData(
              assetCard,
              cryptoData,
              cryptoId,
              lowerCaseVsTicker,
            );
            newAssetCardsList.add(
              await _refreshAnAssetCard(
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

  double _extractNewPriceFromCryptoData(
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

  String _extractNewMktCapStringFromCryptoData(
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

  Future<AssetCard> _refreshAnAssetCard({
    required Asset asset,
    required double newPrice,
    required String newMarketCapString,
    // double extendedHoursPrice = 0,
  }) async {
    return AssetCard(
      key: UniqueKey(),
      asset: asset,
      vsTicker: _vsTicker,
      price: newPrice,
      marketCapString: newMarketCapString,
      // extendedHoursPrice: extendedHoursPrice,
    );
  }

  void _sortAssetCards() {
    setState(
      () {
        _assetCardsList.sort(
          ((a, b) => _getSortTypeToFunctionMap()[_sortType](a, b)),
        );
      },
    );
  }

  int _sortTotalValue(AssetCard a, AssetCard b) {
    return _sort(
      a,
      b,
    );
  }

  int _sortMarketCap(AssetCard a, AssetCard b) {
    return _sort(
      a,
      b,
    );
  }

  int _sortPrice(AssetCard a, AssetCard b) {
    return _sort(
      a,
      b,
    );
  }

  int _sortQuantity(AssetCard a, AssetCard b) {
    return _sort(
      a,
      b,
    );
  }

  int _sortName(AssetCard a, AssetCard b) {
    return _sort(
      b,
      a,
    );
  }

  Map<SortType, dynamic> _getSortTypeToFunctionMap() {
    return {
      SortType.totalValue: _sortTotalValue,
      SortType.marketCap: _sortMarketCap,
      SortType.price: _sortPrice,
      SortType.quantity: _sortQuantity,
      SortType.name: _sortName,
    };
  }

  int _sort(AssetCard a, AssetCard b) {
    Map<SortType, Function(AssetCard)> propertyValues = {
      SortType.totalValue: (card) => card.totalValue,
      SortType.marketCap: (card) => card.asset.marketCap,
      SortType.price: (card) => card.price,
      SortType.quantity: (card) => card.asset.quantity,
      SortType.name: (card) => card.asset.name
    };
    dynamic value1 = propertyValues[_sortType]!(a);
    dynamic value2 = propertyValues[_sortType]!(b);
    return _ascending ? value1.compareTo(value2) : value2.compareTo(value1);
  }

  void toggleSortDirectionAscending() {
    setState(
      () {
        _ascending = !_ascending;
      },
    );
  }

  SortType _getSortTypeFromString(
    String sortTypeString,
  ) {
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

  void _setSortType(SortType newSortType) {
    setState(() {
      _sortType = newSortType;
    });
    _saveSortType();
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
            sortCallback: _sortAssetCards,
            setSortTypeCallback: _setSortType,
            currentSortType: _sortType,
          ),
          RefreshAppBarIcon(
            onRefreshedCallback: _refreshAssetCards,
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
                _netWorth,
              ),
              vsTicker: _vsTicker,
              onNetWorthClickCallback: _onNetWorthButtonPressed,
            ),
            Expanded(
              child: AssetCardDisplay(
                key: UniqueKey(),
                assetList: _assetCardsList,
                deleteAssetCardCallback: _deleteAssetCard,
                editAssetCardQuantityCallback: _editQuantity,
                onRefreshedCallback: _refreshAssetCards,
              ),
            ),
            AddNewAssetButton(
              addNewAssetCallback: _addNewAssetScreen,
            ),
          ],
        ),
      ),
    );
  }
}
