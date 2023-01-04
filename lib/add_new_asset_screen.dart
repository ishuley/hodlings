// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'api_service.dart';
import 'accept_cancel_button.dart';
import 'asset.dart';
import 'package:search_choices/search_choices.dart';
import 'main.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

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
  static const stockDataSourcesList = <String>[
    'Manual Qty',
    // 'Transfer Agent',
    // 'Broker API',
  ];

  /// The types of input possible for a given asset category.
  ///
  /// These lists of possible data sources represent ways the user can input
  /// how many of a given asset they own, which one is used is based on what the
  /// user chooses in [AssetTypeSelection]. Hardcoded because these approaches
  /// will only rarely change, if ever.
  ///
  static const cryptoDataSourcesList = <String>[
    'Manual Qty',
    // 'Blockchain Address',
    // 'Exchange API',
  ];

  /// The types of input possible for a given asset category.
  ///
  /// These lists of possible data sources represent ways the user can input
  /// how many of a given asset they own, which one is used is based on what the
  /// user chooses in [AssetTypeSelection]. Hardcoded because these approaches
  /// will only rarely change, if ever.
  ///
  static const cashDataSourcesList = <String>[
    'Manual Qty',
    // 'Bank API',
  ];

  @override
  State<AddNewAssetScreen> createState() => _AddNewAssetScreenState();
}

class _AddNewAssetScreenState extends State<AddNewAssetScreen> {
  /// The currently selected data source.
  ///
  /// Stores the current single asset displayed in [DataSourceDropdown]
  /// by default (ie, Manual Qty, Blockchain Address, etc...).
  ///
  String currentDataSource = AddNewAssetScreen.stockDataSourcesList.first;

  /// List of [DataSourceDropdown] options.
  ///
  /// Defaults to stocks because because that's the arbitrarily chosen default
  /// [assetType] selected in [AssetTypeSelection].
  ///
  List<String> dataSourceDropdownValues =
      AddNewAssetScreen.stockDataSourcesList;

  /// The currently selected asset type.
  ///
  /// Enum from Asset.dart representing which type of asset is currently
  /// selected by [AssetTypeSelection]. Also tells main.dart which API is
  /// needed to retrieve each individual asset's price.
  ///
  AssetType assetType = AssetType.stock;

  /// Stores the currently selected asset from [AssetDropdown].
  ///
  /// This is passed back to the main.dart to tell the program which asset's
  /// price it needs to retrieve from the API.
  ///
  String currentlySelectedAsset = "GME - Gamestop Corporation - Class A";

  /// This label identifies what is supposed to go in [DataSourceDropdown].
  ///
  /// Stock is the default [assetType] so the default data source (chosen
  /// arbitrarily) is coincidentally manual entry, until API functionality is
  /// added.
  ///
  String currentDataSourceLabel = "Enter quantity manually:";

  /// Indicates if the current data source makes sense to input with a QR code.
  ///
  /// If [currentDataSource] is scannable, then the implication is that they
  /// want to enter an API key or a blockchain address, and nobody wants to key
  /// those in by hand. They will either scan a QR code or paste the data.
  /// Therefore if this property is true, I throw up a QR code icon and
  /// disable the keyboard.
  ///
  bool dataSourceScannable = false;

  /// QR code scan results.
  ///
  /// This property stores the result of a QR code scan, initiated from
  /// clicking the icon in [DataSourceTextField]. This data should either be a
  /// blockchain address or an API key once that gets implemented.
  ///
  String qrCodeResult = '';

  /// The type of keyboard that should be associated with a given [TextField].
  ///
  /// This stores the currently needed type of keyboard necessary to enter data
  /// about quantity into [DataSourceTextField] or to specify an asset in
  /// [AssetDropdown].
  ///
  TextInputType dataSourceTextFieldKeyboard =
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
  List<String> stockAssetNamesAndTickers = [];

  /// Lists of strings to be converted into [DropdownMenuItem]s for
  /// [AssetDropdown].
  ///
  /// I chose to store the String Lists for each asset category in their own
  /// lists to increase speed in switching between them, at the cost of memory.
  /// This makes changing the value of [AssetTypeSelection] much faster
  /// because [AssetDropdown] does not need to execute an API call every single
  /// time.
  ///
  List<String> cryptoAssetNamesAndTickers = [];

  /// Lists of strings to be converted into [DropdownMenuItem]s for
  /// [AssetDropdown].
  ///
  /// I chose to store the String Lists for each asset category in their own
  /// lists to increase speed in switching between them, at the cost of memory.
  /// This makes changing the value of [AssetTypeSelection] much faster
  /// because [AssetDropdown] does not need to execute an API call every single
  /// time.
  ///
  List<String> cashAssetNamesAndTickers = [];

  /// Determines whether the necessary API data is loaded.
  ///
  /// When loading [AddNewAssetScreen] the API call or persistent data
  /// retrieval, as the case may be, sometimes takes a few seconds, so this
  /// boolean tells the app whether to throw up a progress indicator to let the
  /// user know that it is thinking and hasn't crashed.
  ///
  bool progressIndicatorVisible = true;

  String currentVsTicker = "usd";

  TextEditingController dataSourceInputController = TextEditingController();

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
    initAssetNamesAndTickerListForAssetDropdown();
  }

  /// Assigns a list of [AssetDropdown] choices to the appropriate variable.
  ///
  /// Called upon initialization of the program to establish the default
  /// choices for [AssetDropdown], based on API data.
  /// [getAssetNameAndTickerMapListFromApi] gets the raw data from the appropriate
  /// API, and [parseAssetNameAndTickerMapListIntoStrings] converts
  /// it into a format appropriate for [AssetDropdown] to use.
  ///
  void initAssetNamesAndTickerListForAssetDropdown() async {
    AssetListStorage assetListStorage = AssetListStorage();

    for (AssetType assetType in AssetType.values) {
      List<String> assetNamesAndTickers =
          await getSavedAssetList(assetListStorage, assetType);

      if (assetNamesAndTickers.isEmpty) {
        // There is a bug that occurs when we end up here but yet a file still
        // exists. If we don't delete the entire file on the next line, it will
        // demand an API call every time AddNewAssetScreen is accessed after
        // the asset list changes, and defeat the entire point of all this
        // logic.
        assetListStorage.deleteAssetListFile(assetType);
        assetNamesAndTickers = await retrieveAssetListFromApi(assetType);
        rearrangeAssetListToMyPersonalConvenience(
            assetType, assetNamesAndTickers);
      }
      setState(() {
        if (assetNamesAndTickers.isNotEmpty) {
          initializeAnAssetListWithSavedDataOrApiData(
              assetNamesAndTickers, assetType);
          assetListStorage.writeAssetList(assetNamesAndTickers, assetType);
        }
        if (assetNamesAndTickers.isEmpty) {
          initializeAnEmptyAssetList(assetType);
        }
      });
    }
    setState(() {
      progressIndicatorVisible = !progressIndicatorVisible;
    });
  }

  /// Retrieves and parses a list of tickers and their names from the API.
  ///
  /// Gets a [List] of [Map] objects from the API and parses them into a list
  /// [String]s appropriate for use in [AssetDropdown].
  ///
  Future<List<String>> retrieveAssetListFromApi(AssetType assetType) async {
    List<Map<String, String>> assetNameAndTickerMapList =
        await getAssetNameAndTickerMapListFromApi(assetType);
    if (assetNameAndTickerMapList.isNotEmpty) {
      List<String> assetNamesAndTickers =
          parseAssetNameAndTickerMapListIntoStrings(assetNameAndTickerMapList);
      assetNamesAndTickers.sort();

      return assetNamesAndTickers;
    }
    return [];
  }

  /// Goes in and rearranges the asset lists to put the assets I like first.
  ///
  /// Not financial advice.
  ///
  /// Thank you for auditing my code.
  ///
  void rearrangeAssetListToMyPersonalConvenience(
      AssetType assetType, List<String> assetNamesAndTickers) {
    if (assetType == AssetType.stock) {
      int gmeIndex =
          assetNamesAndTickers.indexOf("GME - Gamestop Corporation - Class A");
      assetNamesAndTickers.insert(0, assetNamesAndTickers.removeAt(gmeIndex));
    }
    if (assetType == AssetType.crypto) {
      int ethIndex = assetNamesAndTickers.indexOf("ETH - Ethereum");
      assetNamesAndTickers.insert(0, assetNamesAndTickers.removeAt(ethIndex));
      int xmrIndex = assetNamesAndTickers.indexOf("XMR - Monero");
      assetNamesAndTickers.insert(1, assetNamesAndTickers.removeAt(xmrIndex));
      int lrcIndex = assetNamesAndTickers.indexOf("LRC - Loopring");
      assetNamesAndTickers.insert(2, assetNamesAndTickers.removeAt(lrcIndex));
      int imxIndex = assetNamesAndTickers.indexOf("IMX - ImmutableX");
      assetNamesAndTickers.insert(3, assetNamesAndTickers.removeAt(imxIndex));
      int mkrIndex = assetNamesAndTickers.indexOf("MKR - Maker");
      assetNamesAndTickers.insert(4, assetNamesAndTickers.removeAt(mkrIndex));
      int bchIndex = assetNamesAndTickers.indexOf("BCH - Bitcoin Cash");
      assetNamesAndTickers.insert(5, assetNamesAndTickers.removeAt(bchIndex));
    }
    if (assetType == AssetType.cash) {
      int usdIndex = assetNamesAndTickers.indexOf("USD - United States Dollar");
      assetNamesAndTickers.insert(0, assetNamesAndTickers.removeAt(usdIndex));
      int cadIndex = assetNamesAndTickers.indexOf("CAD - Canadian Dollar");
      assetNamesAndTickers.insert(1, assetNamesAndTickers.removeAt(cadIndex));
      int eurIndex = assetNamesAndTickers.indexOf("EUR - Euro");
      assetNamesAndTickers.insert(2, assetNamesAndTickers.removeAt(eurIndex));
      int uyuIndex = assetNamesAndTickers.indexOf("UYU - Uruguayan Peso");
      assetNamesAndTickers.insert(3, assetNamesAndTickers.removeAt(uyuIndex));
    }
  }

  /// Attempts to retrieve an asset list from persistent storage.
  ///
  /// To save on API calls, [initAssetNamesAndTickerListForAssetDropdown]
  /// first checks persistent storage to see if the needed list has already
  /// been downloaded, and if so uses that instead.
  ///
  Future<List<String>> getSavedAssetList(
      AssetListStorage storage, AssetType assetType) async {
    List<String> assetListFromStorage = await storage.readAssetList(assetType);
    return assetListFromStorage;
  }

  /// Initializes the lists that [AssetDropdown] if any are to be found.
  ///
  /// After persistent storage and the API is checked for a suitable list,
  /// the objects representing those lists in memory are initialized for the
  /// first time if either exist.
  ///
  void initializeAnAssetListWithSavedDataOrApiData(
      List<String> assetNamesAndTickers, AssetType assetType) {
    if (assetType == AssetType.stock) {
      stockAssetNamesAndTickers = assetNamesAndTickers;
      currentlySelectedAsset = assetNamesAndTickers.first;
    }
    if (assetType == AssetType.crypto) {
      cryptoAssetNamesAndTickers = assetNamesAndTickers;
    }
    if (assetType == AssetType.cash) {
      cashAssetNamesAndTickers = assetNamesAndTickers;
    }
  }

  /// Initializes [AssetDropdown]'s [DropdownMenuItem]s with empty lists.
  ///
  /// In the event an appropriate list can't be found, we use an empty list so
  /// that the program can move forward with the other [assetType] options.
  /// currentlySelectedAsset is only specified for stocks because it
  /// changes if the [assetType] changes, and [assetTypeChanged] handles the
  /// error message in that situation.
  ///
  void initializeAnEmptyAssetList(AssetType assetType) {
    if (assetType == AssetType.stock) {
      stockAssetNamesAndTickers = [];
      currentlySelectedAsset = "Apologies, the list somehow failed to load.";
    }
    if (assetType == AssetType.crypto) {
      cryptoAssetNamesAndTickers = [];
    }
    if (assetType == AssetType.cash) {
      cashAssetNamesAndTickers = [];
    }
  }

  /// Retrieves a list of [Map] objects corresponding to individual assets.
  ///
  /// Each [Map] object encapsulates the details of a single asset. This
  /// method retrieves a list of those objects to be parsed by
  /// [parseAssetNameAndTickerMapListIntoStrings] into something that
  /// [AssetDropdown] can use for its [DropdownMenuItem]s.
  ///
  Future<List<Map<String, String>>> getAssetNameAndTickerMapListFromApi(
      AssetType assetType) async {
    List<Map<String, String>>? assetNameAndTickerMapList =
        await AssetAPI(assetType).getAssetNamesAndTickers();
    return assetNameAndTickerMapList;
  }

  /// Parses API data into a list of strings for [AssetDropdown]'s options.
  ///
  /// [AssetDropdown] accepts a list of strings which it converts into
  /// [DropdownMenuItem]s for the user to search and identify which asset they
  /// wish to track. This method takes a Map result from an API and converts it
  /// into that list.
  ///
  List<String> parseAssetNameAndTickerMapListIntoStrings(
      List<Map<String, String>> assetNameAndTickerMapList) {
    List<Map<String, String>> newAssetNameAndTickerList =
        assetNameAndTickerMapList;
    List<String> newAssetTickerAndNameListForDropdown = [];
    for (var assetNameAndTickerMap in newAssetNameAndTickerList) {
      assetNameAndTickerMap.forEach((ticker, assetName) {
        ticker = ticker.toUpperCase();
        newAssetTickerAndNameListForDropdown.add("$ticker - $assetName");
      });
    }
    return newAssetTickerAndNameListForDropdown;
  }

  /// Chooses the correct data source list.
  ///
  /// The data source lists are hardcoded constants that describe the user's
  /// choices for inputting the quantity of the asset to track.
  /// It returns the appropriate data source depending on the current
  /// [assetType]. For an example, see any of the corresponding properties
  /// like [AddNewAssetScreen.stockDataSourcesList].
  ///
  List<String> getDataSourcesDropdownValues() {
    switch (assetType) {
      case AssetType.stock:
        return AddNewAssetScreen.stockDataSourcesList;
      case AssetType.crypto:
        return AddNewAssetScreen.cryptoDataSourcesList;
      case AssetType.cash:
        return AddNewAssetScreen.cashDataSourcesList;
    }
  }

  /// Resets the data source and assets when [assetType] changes.
  ///
  /// Changes the [DataSourceDropdown], and the [currentlySelectedAsset] in
  /// [AssetDropdown] to reflect the fact that the user changed the [assetType]
  /// using [AssetTypeSelection].
  ///
  void assetTypeChanged(int currentAssetSelection) async {
    setState(
      () {
        assetType = determineAssetTypeFromSelection(currentAssetSelection);

        List<String> currentAssetList =
            chooseAssetDropdownMenuItemsBasedOnAssetType();
        if (currentAssetList.isNotEmpty) {
          currentlySelectedAsset = currentAssetList.first;
        }
        if (currentAssetList.isEmpty) {
          currentlySelectedAsset =
              "Apologies, the list somehow failed to load.";
        }

        dataSourceDropdownValues = getDataSourcesDropdownValues();
        currentDataSource = dataSourceDropdownValues.first;
        // TODO make currentAssetName remember the last asset selected from a category after changing

        dataSourceChanged(currentDataSource);
      },
    );
  }

  /// Triggered by the onChange listener in [DataSourceDropdown].
  ///
  /// Sets the current data source to a passed in String that comes from the
  /// current user-selected value in [DataSourceDropdown].
  ///
  void dataSourceChanged(String dataSource) {
    setState(() {
      currentDataSource = dataSource;
      updateDataSourceScanability();
      updateDataSourceKeyboardType();
      updateDataSourceLabel();
    });
  }

  /// Translates a passed in int [assetSelection] into a corresponding enum value.
  ///
  /// This is primarily for the legibility of code within [AssetTypeSelection]
  /// and other relevant widgets, as well as the API service and Asset files.
  ///
  AssetType determineAssetTypeFromSelection(int assetSelection) {
    switch (assetSelection) {
      case 0:
        return AssetType.stock;
      case 1:
        return AssetType.crypto;
      case 2:
        return AssetType.cash;
    }
    throw ArgumentError(
        "Unsupported AssetType somehow selected in AssetTypeSelection.");
  }

  /// Triggered by the onChange listener by a callback function occuring within
  /// [AssetDropdown].
  ///
  /// Sets the [currentlySelectedAsset] when the user changes it.
  ///
  void assetDropdownChanged(String currentAssetName) {
    setState(() {
      currentlySelectedAsset = currentAssetName;
    });
  }

  /// Updates [currentDataSource]'s onscreen keyboard type.
  ///
  /// Sets the keyboard type to whichever is most appropriate for the type of
  /// data to be entered. Numeric keyboard to entere a quantity, and disables
  /// it entirely if it's a blockchain address or a QR code.
  ///
  void updateDataSourceKeyboardType() {
    if (currentDataSource.endsWith("API") ||
        currentDataSource.endsWith("Address")) {
      dataSourceTextFieldKeyboard = TextInputType
          .none; // Nobody is going to want to type in an entire blockchain
      // address by hand on a phone, so this disables the keyboard for that use
      return;
    }
    if (currentDataSource.endsWith("Qty") ||
        currentDataSource.endsWith("Agent")) {
      dataSourceTextFieldKeyboard =
          const TextInputType.numberWithOptions(decimal: true);
    }
  }

  /// Sets scannability property related to the [currentDataSource].
  ///
  /// Sets [dataSourceScannable] to indicate whether an option to scan a QR
  /// code should exist given the type of data source.
  ///
  void updateDataSourceScanability() {
    if (currentDataSource.endsWith("API") ||
        currentDataSource.endsWith("Address")) {
      dataSourceScannable = true;
      return;
    }
    if (currentDataSource.endsWith("Qty") ||
        currentDataSource.endsWith("Agent")) {
      dataSourceScannable = false;
    }
  }

  /// Determines how to label the data source input text field.
  ///
  /// Provides a [String] used by [DataSourceLabel] to inform the user what kind
  /// of data source is currently selected by [DataSourceDropdown].
  ///
  void updateDataSourceLabel() {
    if (currentDataSource.endsWith("API")) {
      currentDataSourceLabel = "Enter Read-Only API Key: ";
    }
    if (currentDataSource.endsWith("Address")) {
      currentDataSourceLabel = "Enter blockchain address: ";
    }
    if (currentDataSource.endsWith("Qty") ||
        currentDataSource.endsWith("Agent")) {
      currentDataSourceLabel = "Enter quantity manually: ";
    }
    throw UnsupportedError(
        "Unknown data source when getDataSourceLabel() is called.");
  }

  /// Called when the user presses the QR code icon.
  ///
  /// Triggered by a callback function passed into [DataSourceTextField] to
  /// indicate that the user would like to enter data by scanning a QR code.
  /// This is likely for a blockchain address or an exchange API that is too
  /// long to key in by hand.
  ///
  Future<void> qrIconPressed() async {
    String qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', false, ScanMode.QR);

    // if (!mounted) return; // TODO remove this entire line if nothing breaks when you finally get to test your QR code scanner

    setState(() {
      qrCodeResult = qrCode;
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
    double? price = await retrievePrice();
    late AssetCard newAssetCard;
    String dataSourceText = dataSourceInputController.text;

    switch (assetType) {
      case AssetType.stock:
        break;
      case AssetType.crypto:
        late Crypto crypto;
        if (currentDataSource.endsWith("Address")) {
          crypto = Crypto.byAddress(currentlySelectedAsset,
              address: dataSourceInputController.text);
        }
        if (currentDataSource.endsWith("Qty")) {
          double dataSrcAsDouble = double.parse(dataSourceText);
          crypto = Crypto(currentlySelectedAsset, qty: dataSrcAsDouble);
        }
        double? marketCap =
            await crypto.getMarketCap(vsTicker: currentVsTicker);
        String formattedMktCap = NumberFormat().format(marketCap);
        String marketCapString =
            "Market Cap: $formattedMktCap ${currentVsTicker.toUpperCase()}";

        newAssetCard = AssetCard(
          asset: crypto,
          price: price,
          marketCapString: marketCapString,
          vsTicker: currentVsTicker,
        );
        break;
      case AssetType.cash:
        break;
    }

    popContextWithCard(newAssetCard);
  }

  Future<double> retrievePrice() async {
    List<String> splitCurrentlySelectedAsset =
        currentlySelectedAsset.split(" - ");
    String currentTicker = splitCurrentlySelectedAsset.elementAt(0);
    return await AssetAPI(assetType)
        .getPrice(ticker: currentTicker, vsTicker: currentVsTicker);
  }

  /// Pops the context and newly created [AssetCard] back to [MainScreen].
  ///
  /// Destroys [AddNewAssetScreen] and sends the relevant data back to the
  /// parent, [MainScreen] for processing.
  ///
  Future<void> popContextWithCard(AssetCard newAssetCard) async {
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
  List<String> chooseAssetDropdownMenuItemsBasedOnAssetType() {
    switch (assetType) {
      case AssetType.stock:
        return stockAssetNamesAndTickers;
      case AssetType.crypto:
        return cryptoAssetNamesAndTickers;
      case AssetType.cash:
        return cashAssetNamesAndTickers;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("Add New Asset"),
          foregroundColor: Colors.white70,
          centerTitle: true,
          backgroundColor: Colors.grey[900],
        ),
        body: Container(
          color: Colors.black54,
          child: Center(
            child: progressIndicatorVisible
                ? const CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.black,
                    strokeWidth: 10.0,
                  )
                : Container(
                    color: Colors.grey[850],
                    child: Column(
                      children: [
                        AssetTypeSelection(
                            assetTypeChangedCallback: assetTypeChanged),
                        DataSourceDropdown(
                            currentDataSource: currentDataSource,
                            dataSourceDropdownValues: dataSourceDropdownValues,
                            dataSourceChangedCallback: dataSourceChanged),
                        AssetDropdown(
                          currentAssetName: currentlySelectedAsset,
                          assetType: assetType,
                          assetDropdownChangedCallback: assetDropdownChanged,
                          assetTickerAndNameList:
                              chooseAssetDropdownMenuItemsBasedOnAssetType(),
                        ),
                        DataSourceLabel(
                            dataSourceLabel: currentDataSourceLabel),
                        DataSourceTextField(
                          dataSourceScannable: dataSourceScannable,
                          qrIconPressedCallback: qrIconPressed,
                          qrCodeResult: qrCodeResult,
                          dataSourceTextFieldKeyboard:
                              dataSourceTextFieldKeyboard,
                          dataSourceInputController: dataSourceInputController,
                        ),
                        AcceptCancelButton(
                          acceptPushedCallback: onAcceptButtonPressed,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// The rounded selection widget at the top of [AddNewAssetScreen].
///
/// Labeled "Stocks | Crypto | Cash" this widget lets the user select which
/// [AssetType] to add to their portfolio.
///
class AssetTypeSelection extends StatefulWidget {
  final ValueChanged<int> assetTypeChangedCallback;
  const AssetTypeSelection({
    super.key,
    required this.assetTypeChangedCallback,
  });
  @override
  State<AssetTypeSelection> createState() => _AssetTypeSelectionState();
}

class _AssetTypeSelectionState extends State<AssetTypeSelection> {
  int _assetSelection = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: CupertinoSlidingSegmentedControl(
          groupValue: _assetSelection,
          onValueChanged: (int? choice) {
            widget.assetTypeChangedCallback(choice!);
            setState(() {
              _assetSelection = choice;
            });
          },
          backgroundColor: Colors.black38,
          thumbColor: Colors.black,
          children: const {
            0: Text('Stocks', style: TextStyle(color: Colors.white)),
            1: Text('Crypto', style: TextStyle(color: Colors.white)),
            2: Text('Cash', style: TextStyle(color: Colors.white)),
            // 3: Text('NFT', style: TextStyle(color: Colors.white)),
          },
        ),
      ),
    );
  }
}

/// A [DropdownButton] menu where the user selects their quantity source.
///
/// Quanity can be specified manually, through a blockchain address that
/// automatically keeps itself updated, or when implemented, a Read-only
/// exchange API key.
///
class DataSourceDropdown extends StatelessWidget {
  final String currentDataSource;
  final List<String> dataSourceDropdownValues;
  final ValueChanged<String> dataSourceChangedCallback;
  const DataSourceDropdown(
      {super.key,
      required this.currentDataSource,
      required this.dataSourceDropdownValues,
      required this.dataSourceChangedCallback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        onChanged: ((String? selectedDataSource) {
          dataSourceChangedCallback(selectedDataSource!);
        }),
        value: currentDataSource,
        items: dataSourceDropdownValues
            .map<DropdownMenuItem<String>>((String dataSourceName) {
          return DropdownMenuItem<String>(
            value: dataSourceName,
            child: Text(dataSourceName),
          );
        }).toList(),
        isExpanded: true,
        style: const TextStyle(color: Colors.white),
        dropdownColor: Colors.grey[900],
        iconEnabledColor: Colors.white,
        iconDisabledColor: Colors.grey,
      ),
    );
  }
}

/// A [SearchChoices] object that lets the user specify the desired [Asset].
///
/// [Asset]s come from a different API for each possible [AssetType].
/// [SearchChoices] is a type of [DropdownButton] that permits the user to
/// search for the desired [Asset] in addition to clicking on it as a
/// conventional [DropdownButton].
///
class AssetDropdown extends StatelessWidget {
  final AssetType assetType;
  final String currentAssetName;
  final ValueChanged<String> assetDropdownChangedCallback;
  final List<String> assetTickerAndNameList;

  const AssetDropdown({
    super.key,
    required this.assetType,
    required this.currentAssetName,
    required this.assetDropdownChangedCallback,
    required this.assetTickerAndNameList,
  });

  List<DropdownMenuItem> mapListForDropdown() {
    List<DropdownMenuItem> assetNameDropdownItemsList = [];
    for (String tickerAndNameString in assetTickerAndNameList) {
      assetNameDropdownItemsList.add(DropdownMenuItem(
          value: tickerAndNameString, child: Text(tickerAndNameString)));
    }
    return assetNameDropdownItemsList;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: SearchChoices.single(
        items: mapListForDropdown(),
        value: currentAssetName,
        hint: Text(
          currentAssetName,
          style: const TextStyle(color: Colors.black),
        ),
        searchHint: const Text(
          "Select asset",
          style: TextStyle(color: Colors.black),
        ),
        style: const TextStyle(color: Colors.white),
        closeButton: TextButton(
          onPressed: (() => {Navigator.pop(context)}),
          child: const Text(
            "Close",
            style: TextStyle(color: Colors.black),
          ),
        ),
        menuBackgroundColor: Colors.grey[350],
        iconEnabledColor: Colors.white,
        iconDisabledColor: Colors.grey,
        onChanged: ((String? chosenAssetName) {
          assetDropdownChangedCallback(chosenAssetName!);
        }),
        isExpanded: true,
        displayClearIcon: false,
      ),
    );
  }
}

/// A simple [Text] object to label the [DataSourceTextField].
///
/// Instructs the user what to enter in the [DataSourceTextField] directly
/// beneath this widget.
///
class DataSourceLabel extends StatelessWidget {
  const DataSourceLabel({super.key, required this.dataSourceLabel});

  final String dataSourceLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 24.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child:
            Text(dataSourceLabel, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

/// Enter the source of user's [Asset] quantity data and other related data.
///
/// Can accept a manual entry, a blackchain address, or later, an exchange API
/// key.
///
class DataSourceTextField extends StatefulWidget {
  const DataSourceTextField({
    super.key,
    required this.dataSourceScannable,
    required this.qrIconPressedCallback,
    required this.qrCodeResult,
    required this.dataSourceTextFieldKeyboard,
    required this.dataSourceInputController,
  });
  final bool dataSourceScannable;
  final VoidCallback qrIconPressedCallback;
  final String qrCodeResult;
  final TextInputType dataSourceTextFieldKeyboard;
  final TextEditingController dataSourceInputController;

  @override
  State<DataSourceTextField> createState() => _DataSourceTextFieldState();
}

class _DataSourceTextFieldState extends State<DataSourceTextField> {
  @override
  void initState() {
    super.initState();
    widget.dataSourceInputController.addListener(
      () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 50.0,
        child: TextField(
          controller: widget.dataSourceInputController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            fillColor: Colors.black38,
            filled: true,
            suffixIcon: widget.dataSourceInputController.text.isEmpty
                ? widget.dataSourceScannable
                    ? IconButton(
                        onPressed: onQRIconPressed,
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white60,
                        ),
                      )
                    : Container(width: 0)
                : IconButton(
                    onPressed: () => widget.dataSourceInputController.clear(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white60,
                    ),
                  ),
          ),
          style: const TextStyle(color: Colors.white),
          keyboardType: widget.dataSourceTextFieldKeyboard,
        ),
      ),
    );
  }

  void onQRIconPressed() {
    widget.qrIconPressedCallback();
    widget.dataSourceInputController.text = widget.qrCodeResult;
  }
}

/// Presistent storage for the lists of selectable assets.
///
/// The [DropdownMenuItem]s used by [AssetDropdown] come from an API call,
/// which is expensive for a poor dev like me. I choose to make the API calls
/// once, then provide a [DrawerMenu.RefreshAssetsButton] to let the user
/// manually refresh them in the event a new security comes along that is not
/// yet listed. This class encapsulates the necessary persistent storage logic.
///
class AssetListStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> get _stockAssetListFile async {
    final path = await _localPath;
    return File('$path/stockAssetList.txt');
  }

  Future<File> get _cryptoAssetListFile async {
    final path = await _localPath;
    return File('$path/cryptoAssetList.txt');
  }

  Future<File> get _cashAssetListFile async {
    final path = await _localPath;
    return File('$path/cashAssetList.txt');
  }

  Future<List<String>> readAssetList(AssetType assetType) async {
    try {
      final File file = await chooseAssetFile(assetType);
      return await file.readAsLines();
    } catch (e) {
      return [];
    }
  }

  Future<void> writeAssetList(
      List<String> assetList, AssetType assetType) async {
    File file = await chooseAssetFile(assetType);

    for (String assetTickerAndName in assetList) {
      file = await file.writeAsString("$assetTickerAndName\n",
          mode: FileMode.append);
    }
  }

  Future<File> chooseAssetFile(AssetType assetType) async {
    switch (assetType) {
      case AssetType.stock:
        return await _stockAssetListFile;
      case AssetType.crypto:
        return await _cryptoAssetListFile;
      case AssetType.cash:
        return await _cashAssetListFile;
    }
  }

  Future<void> deleteAssetListFile(AssetType assetType) async {
    File assetListFile = await chooseAssetFile(assetType);
    if (await assetListFile.exists()) {
      assetListFile.delete();
    }
  }
}
