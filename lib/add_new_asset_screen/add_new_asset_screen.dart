import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hodlings/add_new_asset_screen/asset_dropdown.dart';
import 'package:hodlings/add_new_asset_screen/asset_type_selection.dart';
import 'package:hodlings/add_new_asset_screen/data_source_input.dart';
import 'package:hodlings/api_service/api_service.dart';
import 'package:hodlings/main_screen/asset.dart';
import 'package:hodlings/main_screen/asset_display/asset_card.dart';
import 'package:hodlings/persistence/asset_data_item.dart';
import 'package:hodlings/persistence/asset_dropdown_item.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'accept_cancel_button.dart';
import '../persistence/asset_storage.dart';
import '../main.dart';
import 'data_source_dropdown.dart';

// "Ticker" and "symbol" mean the same thing throughout this program. They
// both refer to the 3-5 character identifier used to identify securities, for
// example, "ETH" is Ethereum's ticker/symbol. I try to stick with "ticker" but
// an API might occasionally phrase it as "symbol."

/// Screen where the user specifies a new [Asset] to be added to an [AssetCard].
///
/// Displays a form to specify an asset and quantitiy or a source for a
/// quantity to be added to the portfolio and tracked, which is the primary
/// purpose for this app.
///
class AddNewAssetScreen extends StatefulWidget {
  const AddNewAssetScreen({super.key});

  /// The types of input possible for a given asset category.
  ///
  /// These lists of possible data sources represent ways the user can input
  /// how many of a given asset they own, which one is used is based on what the
  /// user chooses in [AssetTypeSelection]. Hardcoded because these approaches
  /// will only rarely change, if ever.
  ///
  static const _stockDataSourcesList = {
    'Manual Qty',
    // 'Broker API',
  };

  /// The types of input possible for a given asset category.
  ///
  /// These lists of possible data sources represent ways the user can input
  /// how many of a given asset they own, which one is used is based on what the
  /// user chooses in [AssetTypeSelection]. Hardcoded because these approaches
  /// will only rarely change, if ever.
  ///
  static const _cryptoDataSourcesList = {
    'Manual Qty',
    // 'Blockchain Address',
    // 'Exchange API',
  };

  /// The types of input possible for a given asset category.
  ///
  /// These lists of possible data sources represent ways the user can input
  /// how many of a given asset they own, which one is used is based on what the
  /// user chooses in [AssetTypeSelection]. Hardcoded because these approaches
  /// will only rarely change, if ever.
  ///
  static const _cashDataSourcesList = {
    'Manual Qty',
    // 'Bank API',
  };

  @override
  State<AddNewAssetScreen> createState() => _AddNewAssetScreenState();
}

class _AddNewAssetScreenState extends State<AddNewAssetScreen> {
  /// The currently selected data source.
  ///
  /// Stores the current single asset displayed in [DataSourceDropdown]
  /// by default (ie, Manual Qty, Blockchain Address, etc...).
  ///
  String _currentDataSource = AddNewAssetScreen._stockDataSourcesList.first;

  /// List of [DataSourceDropdown] options.
  ///
  /// Defaults to stocks because because that's the arbitrarily chosen default
  /// [_assetType] selected in [AssetTypeSelection].
  ///
  Set<String> _dataSourceDropdownValues =
      AddNewAssetScreen._stockDataSourcesList;

  /// The currently selected asset type.
  ///
  /// Enum from Asset.dart representing which type of asset is currently
  /// selected by [AssetTypeSelection]. Also tells main.dart which API is
  /// needed to retrieve each individual asset's price.
  ///
  AssetType _assetType = AssetType.stock;

  /// Stores the currently selected asset from [AssetDropdown].
  ///
  /// This is passed back to the main.dart to tell the program which asset's
  /// price it needs to retrieve from the API.
  ///
  String _currentlySelectedAssetDropdownElement = 'GME - GameStop Corp.';

  String? _currentlySelectedAssetId;

  /// This label identifies what is supposed to go in [DataSourceDropdown].
  ///
  /// Stock is the default [_assetType] so the default data source (chosen
  /// arbitrarily) is coincidentally manual entry, until API functionality is
  /// added.
  ///
  String _currentDataSourceLabel = 'Enter quantity manually:';

  /// Indicates if the current data source makes sense to input with a QR code.
  ///
  /// If [_currentDataSource] is scannable, then the implication is that they
  /// want to enter an API key or a blockchain address, and nobody wants to key
  /// those in by hand. They will either scan a QR code or paste the data.
  /// Therefore if this property is true, I throw up a QR code icon and
  /// disable the keyboard.
  ///
  bool _dataSourceScannable = false;

  /// QR code scan results.
  ///
  /// This property stores the result of a QR code scan, initiated from
  /// clicking the icon in [DataSourceTextField]. This data should either be a
  /// blockchain address or an API key once that gets implemented.
  ///
  String _qrCodeResult = '';

  /// The type of keyboard that should be associated with a given [TextField].
  ///
  /// This stores the currently needed type of keyboard necessary to enter data
  /// about quantity into [DataSourceTextField] or to specify an asset in
  /// [AssetDropdown].
  ///
  TextInputType _dataSourceTextFieldKeyboard =
      const TextInputType.numberWithOptions(decimal: true);

  /// Lists of strings to be converted into [DropdownMenuItem]s for
  /// [AssetDropdown].
  ///
  /// I chose to store the String Lists for each asset category in their own
  /// lists to increase speed in switching between them, at the cost of memory.
  /// This makes changing the value of [AssetTypeSelection] much faster
  /// because [AssetDropdown] does not need to execute an API call every single
  /// time.
  ///
  List<AssetDropdownItem> _stockAssetDropdownItems = [];

  /// Lists of strings to be converted into [DropdownMenuItem]s for
  /// [AssetDropdown].
  ///
  /// I chose to store the String Lists for each asset category in their own
  /// lists to increase speed in switching between them, at the cost of memory.
  /// This makes changing the value of [AssetTypeSelection] much faster
  /// because [AssetDropdown] does not need to execute an API call every single
  /// time.
  ///
  List<AssetDropdownItem> _cryptoAssetDropdownItems = [];

  /// Lists of strings to be converted into [DropdownMenuItem]s for
  /// [AssetDropdown].
  ///
  /// I chose to store the String Lists for each asset category in their own
  /// lists to increase speed in switching between them, at the cost of memory.
  /// This makes changing the value of [AssetTypeSelection] much faster
  /// because [AssetDropdown] does not need to execute an API call every single
  /// time.
  ///
  List<AssetDropdownItem> _cashAssetDropdownItems = [];

  /// Determines whether the necessary API data is loaded.
  ///
  /// When loading [AddNewAssetScreen] the API call or persistent data
  /// retrieval, as the case may be, sometimes takes a few seconds, so this
  /// boolean tells the app whether to throw up a progress indicator to let the
  /// user know that it is thinking and hasn't crashed.
  ///
  bool _progressIndicatorVisible = true;

  final String _currentVsTicker = 'usd';

  late TextEditingController _dataSourceInputController;

  List<AssetDataItem> _stockAssetData = [];
  List<AssetDataItem> _cryptoAssetData = [];
  List<AssetDataItem> _cashAssetData = [];

  /// Assigns the default asset values to [AssetDropdown].
  ///
  /// It is necessary to do this here for the first time because the
  /// callback function that [AssetDropdown] under normal circumstances is
  /// linked to clicking [AssetTypeSelection]. The logic happens in a different
  /// method because it requires an asynchronous API call.
  ///
  @override
  void initState() {
    super.initState();
    _dataSourceInputController = TextEditingController();
    _initAssetDropdownAndData();
  }

  @override
  void dispose() {
    _dataSourceInputController.dispose();
    super.dispose();
  }

  /// Assigns a list of [AssetDropdown] choices to the appropriate variable.
  ///
  /// Called upon initialization of the program to establish the default
  /// choices for [AssetDropdown], based on API data.
  /// [_getAssetData] gets the raw data from the appropriate
  /// API, and [_parseAssetDataIntoDropdownStrings] converts
  /// it into a format appropriate for [AssetDropdown] to use.
  ///
  void _initAssetDropdownAndData() async {
    AssetStorage assetListStorage = AssetStorage();
    List<AssetDataItem> assetData = [];

    for (AssetType assetType in AssetType.values) {
      assetData = await _getAssetData(assetData, assetType);
      _setAnAssetDataList(assetType, assetData);
      // The list I use for the [AssetDropdown] menu is stored separately from
      // the list of data, which contains names, tickers, and and unique identifier.
      List<AssetDropdownItem> assetDropdownItems =
          await assetListStorage.readAssetListFile(assetType);

      if (assetDropdownItems.isEmpty) {
        assetDropdownItems =
            await _retrieveAssetListFromApi(assetType, assetData);
        assetDropdownItems = _rearrangeAssetListToMyPersonalConvenience(
          assetType,
          assetDropdownItems,
        );
        assetListStorage.writeAssetList(assetDropdownItems, assetType);
      }

      setState(() {
        _initializeAssetDropdownButton(assetDropdownItems, assetType);
      });
    }
    _toggleProgressIndicator();
  }

  void _initializeAssetDropdownButton(
    List<AssetDropdownItem> assetDropdownItems,
    AssetType assetType,
  ) {
    if (assetDropdownItems.isNotEmpty) {
      _initializeAnAssetListWithSavedDataOrApiData(
        assetDropdownItems,
        assetType,
      );
    }
    if (assetDropdownItems.isEmpty) {
      _initializeAnEmptyAssetList(assetType);
    }
  }

  Future<List<AssetDataItem>> _getAssetData(
    List<AssetDataItem> assetData,
    AssetType assetType,
  ) async {
    // Check persistent storage for the asset data.
    assetData = await AssetStorage().readAssetData(assetType);
    if (assetData.isEmpty) {
      // Get the list of assets from the API if none found on drive.
      assetData = await AssetAPI(assetType).getListOfAssets();
      // Save it so we don't have to do this API call every time.
      AssetStorage().writeAssetData(assetData, assetType);
    }
    return assetData;
  }

  String _getAssetIdFromName(String assetName, AssetType assetType) {
    List<AssetDataItem> assetDataList =
        chooseAssetDataBasedOnAssetType(assetType);

    for (AssetDataItem assetData in assetDataList) {
      if (assetData.name.toLowerCase() == assetName.toLowerCase()) {
        return assetData.id.toLowerCase();
      }
    }
    return assetName
        .toLowerCase(); // returns name if it can't find a match, because
    // sometimes that works instead with CoinGecko's API.
  }

  List<AssetDataItem> chooseAssetDataBasedOnAssetType(AssetType assetType) {
    switch (assetType) {
      case AssetType.stock:
        return _stockAssetData;
      case AssetType.crypto:
        return _cryptoAssetData;
      case AssetType.cash:
        return _cashAssetData;
    }
  }

  /// Retrieves and parses a list of tickers and their names from the API.
  ///
  /// Gets a [List] of [Map] objects from the API and parses them into a list
  /// [String]s appropriate for use in [AssetDropdown].
  ///
  Future<List<AssetDropdownItem>> _retrieveAssetListFromApi(
    AssetType assetType,
    List<AssetDataItem> newAssetData,
  ) async {
    List<String> assetDropdownStrings = [];
    assetDropdownStrings = _parseAssetDataIntoDropdownStrings(newAssetData);
    assetDropdownStrings.sort();
    return _convertListOfStringsToListOfAssetDropdownItems(
      assetDropdownStrings,
    );
  }

  void _setAnAssetDataList(
    AssetType assetType,
    List<AssetDataItem> newAssetDataMapList,
  ) {
    setState(
      () {
        if (assetType == AssetType.stock) {
          _stockAssetData = newAssetDataMapList;
        }
        if (assetType == AssetType.crypto) {
          _cryptoAssetData = newAssetDataMapList;
        }
        if (assetType == AssetType.cash) {
          _cashAssetData = newAssetDataMapList;
        }
      },
    );
  }

  /// Goes in and rearranges the asset lists to put the assets I like first.
  ///
  /// Not financial advice.
  ///
  /// Thank you for auditing my code.
  ///
  List<AssetDropdownItem> _rearrangeAssetListToMyPersonalConvenience(
    AssetType assetType,
    List<AssetDropdownItem> assetDropdownItems,
  ) {
    List<String> assetDropdownStrings =
        _convertListOfAssetDropdownItemsToListOfStrings(assetDropdownItems);
    if (assetType == AssetType.stock) {
      int gmeIndex =
          assetDropdownStrings.indexOf('GME Gamestop Corporation - Class A');
      assetDropdownStrings.insert(0, assetDropdownStrings.removeAt(gmeIndex));
    }
    if (assetType == AssetType.crypto) {
      int ethIndex = assetDropdownStrings.indexOf('ETH Ethereum');
      assetDropdownStrings.insert(0, assetDropdownStrings.removeAt(ethIndex));
      int xmrIndex = assetDropdownStrings.indexOf('XMR Monero');
      assetDropdownStrings.insert(1, assetDropdownStrings.removeAt(xmrIndex));
      int lrcIndex = assetDropdownStrings.indexOf('LRC Loopring');
      assetDropdownStrings.insert(2, assetDropdownStrings.removeAt(lrcIndex));
      int imxIndex = assetDropdownStrings.indexOf('IMX ImmutableX');
      assetDropdownStrings.insert(3, assetDropdownStrings.removeAt(imxIndex));
      int mkrIndex = assetDropdownStrings.indexOf('MKR Maker');
      assetDropdownStrings.insert(4, assetDropdownStrings.removeAt(mkrIndex));
      int bchIndex = assetDropdownStrings.indexOf('BCH Bitcoin Cash');
      assetDropdownStrings.insert(5, assetDropdownStrings.removeAt(bchIndex));
    }
    if (assetType == AssetType.cash) {
      int usdIndex = assetDropdownStrings.indexOf('USD United States Dollar');
      assetDropdownStrings.insert(0, assetDropdownStrings.removeAt(usdIndex));
      int cadIndex = assetDropdownStrings.indexOf('CAD Canadian Dollar');
      assetDropdownStrings.insert(1, assetDropdownStrings.removeAt(cadIndex));
      int eurIndex = assetDropdownStrings.indexOf('EUR Euro');
      assetDropdownStrings.insert(2, assetDropdownStrings.removeAt(eurIndex));
      int uyuIndex = assetDropdownStrings.indexOf('UYU Uruguayan Peso');
      assetDropdownStrings.insert(3, assetDropdownStrings.removeAt(uyuIndex));
    }
    List<AssetDropdownItem> newAssetDropdownItems =
        _convertListOfStringsToListOfAssetDropdownItems(assetDropdownStrings);
    return newAssetDropdownItems;
  }

  List<AssetDropdownItem> _convertListOfStringsToListOfAssetDropdownItems(
    List<String> assetDropdownStrings,
  ) {
    List<AssetDropdownItem> newAssetDropdownItems = [];
    for (String assetDropdownText in assetDropdownStrings) {
      newAssetDropdownItems.add(
        AssetDropdownItem(assetDropdownText),
      );
    }
    return newAssetDropdownItems;
  }

  List<String> _convertListOfAssetDropdownItemsToListOfStrings(
    List<AssetDropdownItem> assetDropdownItems,
  ) {
    List<String> assetDropdownStrings = [];
    for (AssetDropdownItem assetDropdownItem in assetDropdownItems) {
      assetDropdownStrings.add(assetDropdownItem.assetDropdownString);
    }
    return assetDropdownStrings;
  }

  /// Initializes the lists that [AssetDropdown] if any are to be found.
  ///
  /// After persistent storage and the API is checked for a suitable list,
  /// the objects representing those lists in memory are initialized for the
  /// first time if either exist.
  ///
  void _initializeAnAssetListWithSavedDataOrApiData(
    List<AssetDropdownItem> assetDropdownItems,
    AssetType assetType,
  ) {
    if (assetType == AssetType.stock) {
      _stockAssetDropdownItems = assetDropdownItems;
      _currentlySelectedAssetDropdownElement =
          assetDropdownItems[0].assetDropdownString;
      _setCurrentlySelectedAssetId();
    }
    if (assetType == AssetType.crypto) {
      _cryptoAssetDropdownItems = assetDropdownItems;
    }
    if (assetType == AssetType.cash) {
      _cashAssetDropdownItems = assetDropdownItems;
    }
  }

  String _getNameFromAssetDropdownValue(
    String assetDropdownValue,
    AssetType assetType,
  ) {
    List<String> tickerAndName = assetDropdownValue.split(' ');
    tickerAndName.removeAt(0);
    String assetName = tickerAndName.join(' ');
    return assetName.toLowerCase();
  }

  /// Initializes [AssetDropdown]'s [DropdownMenuItem]s with empty lists.
  ///
  /// In the event an appropriate list can't be found, we use an empty list so
  /// that the program can move forward with the other [assetType] options.
  /// [_currentlySelectedAssetDropdownElement] is only specified for stocks because it
  /// changes if the [assetType] changes, and [_assetTypeChanged] handles the
  /// error message in that situation.
  ///
  void _initializeAnEmptyAssetList(AssetType assetType) {
    if (assetType == AssetType.stock) {
      _stockAssetDropdownItems = [];
      _currentlySelectedAssetDropdownElement =
          'Apologies, the list somehow failed to load.';
      _currentlySelectedAssetId = null;
    }
    if (assetType == AssetType.crypto) {
      _cryptoAssetDropdownItems = [];
    }
    if (assetType == AssetType.cash) {
      _cashAssetDropdownItems = [];
    }
  }

  /// Parses API data into a list of strings for [AssetDropdown]'s options.
  ///
  /// [AssetDropdown] accepts a list of strings which it converts into
  /// [DropdownMenuItem]s for the user to search and identify which asset they
  /// wish to track. This method takes a [Map] result from an API and converts it
  /// into that list.
  ///
  List<String> _parseAssetDataIntoDropdownStrings(
    List<AssetDataItem> assetIdDataMapList,
  ) {
    List<String> assetDropdownStrings = [];
    for (AssetDataItem assetData in assetIdDataMapList) {
      assetDropdownStrings
          .add('${assetData.ticker.toUpperCase()} ${assetData.name}');
    }
    return assetDropdownStrings;
  }

  /// Chooses the correct data source list.
  ///
  /// The data source lists are hardcoded constants that describe the user's
  /// choices for inputting the quantity of the asset to track.
  /// It returns the appropriate data source depending on the current
  /// [_assetType]. For an example, see any of the corresponding properties
  /// like [AddNewAssetScreen._stockDataSourcesList].
  ///
  Set<String> _getDataSourcesDropdownValues() {
    switch (_assetType) {
      case AssetType.stock:
        return AddNewAssetScreen._stockDataSourcesList;
      case AssetType.crypto:
        return AddNewAssetScreen._cryptoDataSourcesList;
      case AssetType.cash:
        return AddNewAssetScreen._cashDataSourcesList;
    }
  }

  /// Resets the data source and assets when [_assetType] changes.
  ///
  /// Changes the [DataSourceDropdown], and the [_currentlySelectedAssetDropdownElement] in
  /// [AssetDropdown] to reflect the fact that the user changed the [_assetType]
  /// using [AssetTypeSelection].
  ///
  void _assetTypeChanged(int currentAssetSelection) async {
    setState(
      () {
        _assetType = _determineAssetTypeFromSelection(currentAssetSelection);

        List<AssetDropdownItem> currentAssetList =
            _chooseAssetDropdownItemListBasedOnAssetType();
        _initCurrentAsset(currentAssetList);

        _dataSourceDropdownValues = _getDataSourcesDropdownValues();
        _currentDataSource = _dataSourceDropdownValues.first;
        // TODO make the app remember the last asset selected from a category after changing categories

        _dataSourceChanged(_currentDataSource);
      },
    );
  }

  void _initCurrentAsset(List<AssetDropdownItem> currentAssetList) {
    if (currentAssetList.isNotEmpty) {
      _currentlySelectedAssetDropdownElement =
          currentAssetList[0].assetDropdownString;
      _setCurrentlySelectedAssetId();
    }
    if (currentAssetList.isEmpty) {
      _currentlySelectedAssetDropdownElement =
          'Apologies, the list somehow failed to load.';
      _currentlySelectedAssetId = null;
    }
  }

  void _setCurrentlySelectedAssetId() {
    String assetName = _getNameFromAssetDropdownValue(
      _currentlySelectedAssetDropdownElement,
      _assetType,
    );
    _currentlySelectedAssetId = _getAssetIdFromName(assetName, _assetType);
  }

  /// Triggered by the onChange listener in [DataSourceDropdown].
  ///
  /// Sets the current data source to a passed in String that comes from the
  /// current user-selected value in [DataSourceDropdown].
  ///
  void _dataSourceChanged(String dataSource) {
    setState(() {
      _currentDataSource = dataSource;
      _updateDataSourceScanability();
      _updateDataSourceKeyboardType();
      _updateDataSourceLabel();
    });
  }

  /// Translates a passed in int [assetSelection] into a corresponding enum value.
  ///
  /// This is primarily for the legibility of code within [AssetTypeSelection]
  /// and other relevant widgets, as well as the API service and Asset files.
  ///
  AssetType _determineAssetTypeFromSelection(int assetSelection) {
    switch (assetSelection) {
      case 0:
        return AssetType.stock;
      case 1:
        return AssetType.crypto;
      case 2:
        return AssetType.cash;
    }
    throw ArgumentError(
      'Unsupported AssetType somehow selected in AssetTypeSelection.',
    );
  }

  /// Triggered by the onChange listener by a callback function occuring within
  /// [AssetDropdown].
  ///
  /// Sets the [_currentlySelectedAssetDropdownElement] when the user changes it.
  ///
  void _assetDropdownChanged(String currentAssetName) {
    setState(() {
      _currentlySelectedAssetDropdownElement = currentAssetName;
      _currentlySelectedAssetId =
          _getAssetIdFromName(currentAssetName, _assetType);
      _setCurrentlySelectedAssetId();
    });
  }

  /// Updates [_currentDataSource]'s onscreen keyboard type.
  ///
  /// Sets the keyboard type to whichever is most appropriate for the type of
  /// data to be entered. Numeric keyboard to entere a quantity, and disables
  /// it entirely if it's a blockchain address or a QR code.
  ///
  void _updateDataSourceKeyboardType() {
    if (_currentDataSource.endsWith('API') ||
        _currentDataSource.endsWith('Address')) {
      _dataSourceTextFieldKeyboard = TextInputType
          .none; // Nobody is going to want to type in an entire blockchain
      // address by hand on a phone, so this disables the keyboard for that use
      return;
    }
    if (_currentDataSource.endsWith('Qty') ||
        _currentDataSource.endsWith('Agent')) {
      _dataSourceTextFieldKeyboard =
          const TextInputType.numberWithOptions(decimal: true);
    }
  }

  /// Sets scannability property related to the [_currentDataSource].
  ///
  /// Sets [_dataSourceScannable] to indicate whether an option to scan a QR
  /// code should exist given the type of data source.
  ///
  void _updateDataSourceScanability() {
    if (_currentDataSource.endsWith('API') ||
        _currentDataSource.endsWith('Address')) {
      _dataSourceScannable = true;
      return;
    }
    if (_currentDataSource.endsWith('Qty') ||
        _currentDataSource.endsWith('Agent')) {
      _dataSourceScannable = false;
    }
  }

  /// Determines how to label the data source input text field.
  ///
  /// Provides a [String] used by [DataSourceLabel] to inform the user what kind
  /// of data source is currently selected by [DataSourceDropdown].
  ///
  void _updateDataSourceLabel() {
    if (_currentDataSource.endsWith('API')) {
      _currentDataSourceLabel = 'Enter Read-Only API Key: ';
      return;
    }
    if (_currentDataSource.endsWith('Address')) {
      _currentDataSourceLabel = 'Enter blockchain address: ';
      return;
    }
    if (_currentDataSource.endsWith('Qty') ||
        _currentDataSource.endsWith('Agent')) {
      _currentDataSourceLabel = 'Enter quantity manually: ';
      return;
    }
    throw UnsupportedError(
      'Unknown data source when getDataSourceLabel() is called.',
    );
  }

  /// Called when the user presses the QR code icon.
  ///
  /// Triggered by a callback function passed into [DataSourceTextField] to
  /// indicate that the user would like to enter data by scanning a QR code.
  /// This is likely for a blockchain address or an exchange API that is too
  /// long to key in by hand.
  ///
  Future<void> _qrIconPressed() async {
    String qrCode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      false,
      ScanMode.QR,
    );

    if (!mounted) return;
    setState(() {
      _qrCodeResult = qrCode;
    });
  }

  /// Indicates that the fields in [AddNewAssetScreen] are ready to submit.
  ///
  /// Triggered by a callback function passed into [AcceptCancelButton] to
  /// indicate that the user is satisfied with the asset and quantities
  /// specified, and is read to add the data to their portfolio. This function
  /// creates a new [AssetCard] object with the specified data, and passes it
  /// back to [MainScreen] by "popping" it along with the context.
  ///
  Future<void> onAcceptButtonPressed() async {
    if (_dataSourceInputController.text.isNotEmpty) {
      _toggleProgressIndicator();
      Asset asset = _assetType.createAsset(
        assetFieldData: _currentlySelectedAssetDropdownElement,
        assetId: _currentlySelectedAssetId!,
        dataSource: _currentDataSource,
        dataSourceField: _dataSourceInputController.text,
      );

      AssetCard newAssetCard = await _createNewAssetCard(asset);
      _toggleProgressIndicator();
      _popContextWithCard(newAssetCard);
    }
  }

  void _toggleProgressIndicator() {
    setState(() {
      _progressIndicatorVisible = !_progressIndicatorVisible;
    });
  }

  Future<AssetCard> _createNewAssetCard(
    Asset asset,
  ) async {
    double price = await _retrievePrice(asset);
    String marketCapString =
        await asset.getMarketCapString(vsTicker: _currentVsTicker);

    AssetCard newAssetCard = AssetCard(
      key: UniqueKey(),
      asset: asset,
      price: price,
      marketCapString: marketCapString,
      vsTicker: _currentVsTicker,
    );
    return newAssetCard;
  }

  Future<double> _retrievePrice(Asset asset) async {
    return await asset.getPrice(vsTicker: 'usd');
  }

  /// Pops the context and newly created [AssetCard] back to [MainScreen].
  ///
  /// Destroys [AddNewAssetScreen] and sends the relevant data back to the
  /// parent, [MainScreen] for processing.
  ///
  Future<void> _popContextWithCard(AssetCard newAssetCard) async {
    Navigator.pop(
      context,
      newAssetCard,
    );
  }

  /// Chooses the correct list of strings for use in [AssetDropdown].
  ///
  /// All three lists of dropdown options were created alongside
  /// [AddNewAssetScreen] itself, therefore the already existing list need only
  /// be referenced by [AssetDropdown].
  ///
  List<AssetDropdownItem> _chooseAssetDropdownItemListBasedOnAssetType() {
    switch (_assetType) {
      case AssetType.stock:
        return _stockAssetDropdownItems;
      case AssetType.crypto:
        return _cryptoAssetDropdownItems;
      case AssetType.cash:
        return _cashAssetDropdownItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Add New Asset'),
          centerTitle: true,
        ),
        body: Center(
          child: _progressIndicatorVisible
              ? const CircularProgressIndicator.adaptive(
                  strokeWidth: 10.0,
                )
              : Column(
                  children: [
                    AssetTypeSelection(
                      assetTypeChangedCallback: _assetTypeChanged,
                    ),
                    DataSourceDropdown(
                      currentDataSource: _currentDataSource,
                      dataSourceDropdownValues: _dataSourceDropdownValues,
                      dataSourceChangedCallback: _dataSourceChanged,
                    ),
                    AssetDropdown(
                      currentAssetName: _currentlySelectedAssetDropdownElement,
                      assetType: _assetType,
                      assetDropdownChangedCallback: _assetDropdownChanged,
                      assetTickerAndNameList:
                          _convertListOfAssetDropdownItemsToListOfStrings(
                        _chooseAssetDropdownItemListBasedOnAssetType(),
                      ),
                    ),
                    DataSourceLabel(dataSourceLabel: _currentDataSourceLabel),
                    DataSourceTextField(
                      dataSourceScannable: _dataSourceScannable,
                      qrIconPressedCallback: _qrIconPressed,
                      qrCodeResult: _qrCodeResult,
                      dataSourceTextFieldKeyboard: _dataSourceTextFieldKeyboard,
                      dataSourceInputController: _dataSourceInputController,
                    ),
                    AcceptCancelButton(
                      acceptPushedCallback: onAcceptButtonPressed,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
