import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'api_service.dart';
import 'accept_cancel_button.dart';
import 'asset.dart';
import 'package:search_choices/search_choices.dart';

class AddNewAssetScreen extends StatefulWidget {
  const AddNewAssetScreen({super.key});

  static const stockDataSourcesList = <String>[
    'Manual Qty',
    // 'Transfer Agent',
    // 'Broker API',
  ];
  static const cryptoDataSourcesList = <String>[
    'Blockchain Address',
    // 'Exchange API',
    'Manual Qty',
  ];
  static const nftDataSourcesList = <String>[
    'Blockchain Address',
    'Manual Qty',
  ];
  static const cashDataSourcesList = <String>[
    'Manual Qty',
    // 'Bank API',
  ];

  @override
  State<AddNewAssetScreen> createState() => _AddNewAssetScreenState();
}

class _AddNewAssetScreenState extends State<AddNewAssetScreen> {
  String currentDataSource = AddNewAssetScreen.stockDataSourcesList.first;
  List<String> dataSourceDropdownValues =
      AddNewAssetScreen.stockDataSourcesList;
  AssetType assetType = AssetType.stock;
  String currentAssetName = "GameStop";
  int assetSelection = 0;
  String currentDataSourceLabel = "Enter quantity manually:";
  bool dataSourceScannable = false;
  String qrCodeResult = '';
  TextInputType dataSourceTextFieldKeyboard =
      const TextInputType.numberWithOptions(decimal: true);
  double manualQty = 0;
  String blockchainAddress = "";

  // This helper function chooses the correct data source list, which is a
  // hardcoded constant above
  List<String> setDataSourcesDropdownValues() {
    switch (assetType) {
      case AssetType.crypto:
        return AddNewAssetScreen.cryptoDataSourcesList;
      case AssetType.nft:
        return AddNewAssetScreen.nftDataSourcesList;
      case AssetType.cash:
        return AddNewAssetScreen.cashDataSourcesList;
      default:
        return AddNewAssetScreen.stockDataSourcesList;
    }
  }

  // This is used by the AssetType CupertinoSegmentedSelection widget as a
  // callback function to update all the fields to reflect a change in the asset
  // type (i.e. stocks, crypto, nfts, cash)
  void assetTypeChanged(int currentAssetSelection) {
    setState(
      () {
        assetSelection = currentAssetSelection;
        determineAssetTypeFromSelection(assetSelection);
        dataSourceDropdownValues = setDataSourcesDropdownValues();
        currentDataSource = dataSourceDropdownValues.first;
        // TODO make currentAssetName remember the last asset selected from a category after changing
        currentAssetName = AssetDataAPI(assetType).getAssetList().first;
        dataSourceChanged(currentDataSource);
      },
    );
  }

  // This translates an int into a word for the purposes of the
  // AssetTypeSelection widget's legibility
  void determineAssetTypeFromSelection(int assetSelection) {
    switch (assetSelection) {
      case 1:
        assetType = AssetType.crypto;
        break;
      case 2:
        assetType = AssetType.nft;
        break;
      case 3:
        assetType = AssetType.cash;
        break;
      default:
        assetType = AssetType.stock;
    }
  }

  // This is called by the DataSourceDropdown's callback function to update
  // the current data source and label in the other widgets
  void dataSourceChanged(String dataSource) {
    setState(() {
      currentDataSource = dataSource;
      updateDataSourceProperties();
      currentDataSourceLabel = getDataSourceLabel();
      //TODO implement broker and exchange API support, then check if the source is an API, then ask which supported exchange or broker they wish to use
    });
  }

  // This is called by the callback function that triggers when the dropdown
  //corresponding to specific securities (AssetDropdown) is changed.
  void assetDropdownChanged(String currentAssetName) {
    setState(() {
      this.currentAssetName = currentAssetName;
      updateDataSourceProperties();
    });
  }

  void updateDataSourceProperties() {
    if (currentDataSource.endsWith("API") ||
        currentDataSource.endsWith("Address")) {
      dataSourceScannable = true;
      dataSourceTextFieldKeyboard = TextInputType
          .none; // Nobody is going to want to type in an entire blockchain
      // address by hand on a phone, so this disables the keyboard for that use
      return;
    }
    if (currentDataSource.endsWith("Qty") ||
        currentDataSource.endsWith("Agent")) {
      dataSourceScannable = false;
      dataSourceTextFieldKeyboard =
          const TextInputType.numberWithOptions(decimal: true);
    }
  }

  // This provides the correct string for DataSourceLabel based on the
  //currently selected data source in DataSourceDropdown
  String getDataSourceLabel() {
    if (currentDataSource.endsWith("API")) {
      return "Enter Read-Only API Key: ";
    }
    if (currentDataSource.endsWith("Address")) {
      return "Enter blockchain address: ";
    }
    if (currentDataSource.endsWith("Qty") ||
        currentDataSource.endsWith("Agent")) {
      return "Enter quantity manually: ";
    }
    throw UnsupportedError(
        "Unknown data source when getDataSourceLabel() is called.");
  }

  Future<void> qrIconPressed() async {
    String qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', false, ScanMode.QR);

    if (!mounted) return;

    setState(() {
      qrCodeResult = qrCode;
    });
  }

  void onAcceptButtonPressed() {
    /// TODO replace this with code that actually builds the specified asset
    AssetCard newAssetCard = AssetCard(
      asset: Crypto("Ethereum", 20.0),
      vsTicker: "USD",
    );

    popContextWithCard(newAssetCard);
  }

  Future<void> popContextWithCard(AssetCard newAssetCard) async {
    Navigator.pop(
      context,
      newAssetCard,
    );
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
          color: Colors.grey[850],
          child: Column(
            children: [
              AssetCategorySelection(
                  assetTypeChangedCallback: assetTypeChanged),
              DataSourceDropdown(
                  currentDataSource: currentDataSource,
                  dataSourceDropdownValues: dataSourceDropdownValues,
                  dataSourceChangedCallback: dataSourceChanged),
              AssetDropdown(
                  currentAssetName: currentAssetName,
                  assetType: assetType,
                  assetDropdownChangedCallback: assetDropdownChanged),
              DataSourceLabel(dataSourceLabel: currentDataSourceLabel),
              DataSourceTextField(
                dataSourceScannable: dataSourceScannable,
                qrIconPressedCallback: qrIconPressed,
                qrCodeResult: qrCodeResult,
                dataSourceTextFieldKeyboard: dataSourceTextFieldKeyboard,
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

// This is the rounded selection widget at the top labelled "Stocks Crypto NFTs Cash"
class AssetCategorySelection extends StatefulWidget {
  // final int assetSelection;
  final ValueChanged<int> assetTypeChangedCallback;
  const AssetCategorySelection({
    super.key,
    required this.assetTypeChangedCallback,
  });
  @override
  State<AssetCategorySelection> createState() => _AssetCategorySelectionState();
}

class _AssetCategorySelectionState extends State<AssetCategorySelection> {
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
            // 2: Text('NFTs', style: TextStyle(color: Colors.white)),
            3: Text('Cash', style: TextStyle(color: Colors.white)),
          },
        ),
      ),
    );
  }
}

// This is the dropdown associated with the data source, which is specific to each Asset category
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
      ),
    );
  }
}

// This dropdown allows the user to specify a security to track
class AssetDropdown extends StatelessWidget {
  final AssetType assetType;
  final String currentAssetName;
  final ValueChanged<String> assetDropdownChangedCallback;

  const AssetDropdown({
    super.key,
    required this.assetType,
    required this.currentAssetName,
    required this.assetDropdownChangedCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      child: SearchChoices.single(
        items: AssetDataAPI(assetType)
            .getAssetList()
            .map<DropdownMenuItem<String>>(
          (String assetName) {
            return DropdownMenuItem<String>(
              value: assetName,
              child:
                  Text(assetName, style: const TextStyle(color: Colors.white)),
            );
          },
        ).toList(),
        value: currentAssetName,
        hint: Text(
          currentAssetName,
          style: const TextStyle(color: Colors.white),
        ),
        searchHint: const Text(
          "Select asset",
          style: TextStyle(color: Colors.white),
        ),
        style: const TextStyle(color: Colors.white),
        closeButton: TextButton(
          onPressed: (() => {Navigator.pop(context)}),
          child: const Text(
            "Close",
            style: TextStyle(color: Colors.white),
          ),
        ),
        menuBackgroundColor: Colors.grey[850],
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

// This is a label to explain the purpose of the textbox that occurs after in the UI
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

class DataSourceTextField extends StatefulWidget {
  const DataSourceTextField({
    super.key,
    required this.dataSourceScannable,
    required this.qrIconPressedCallback,
    required this.qrCodeResult,
    required this.dataSourceTextFieldKeyboard,
  });
  final bool dataSourceScannable;
  final VoidCallback qrIconPressedCallback;
  final String qrCodeResult;
  final TextInputType dataSourceTextFieldKeyboard;

  @override
  State<DataSourceTextField> createState() => _DataSourceTextFieldState();
}

class _DataSourceTextFieldState extends State<DataSourceTextField> {
  final dataSourceInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dataSourceInputController.addListener(
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
          controller: dataSourceInputController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            fillColor: Colors.black38,
            filled: true,
            suffixIcon: dataSourceInputController.text.isEmpty
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
                    onPressed: () => dataSourceInputController.clear(),
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
    dataSourceInputController.text = widget.qrCodeResult;
  }
}
