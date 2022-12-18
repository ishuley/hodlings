import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'api_service.dart';

class AddNewAssetScreen extends StatefulWidget {
  const AddNewAssetScreen({super.key});

  static const stockDataSourcesList = <String>[
    'Manual Qty',
    'Transfer Agent',
    'Broker API',
  ];
  static const cryptoDataSourcesList = <String>[
    'Blockchain Address',
    'Exchange API',
    'Manual Qty',
  ];
  static const nftDataSourcesList = <String>[
    'Blockchain Address',
    'Manual Qty',
  ];
  static const cashDataSourcesList = <String>[
    'Manual Qty',
    'Bank API',
  ];

  @override
  State<AddNewAssetScreen> createState() => _AddNewAssetScreenState();
}

class _AddNewAssetScreenState extends State<AddNewAssetScreen> {
  String currentDataSource = AddNewAssetScreen.stockDataSourcesList.first;
  List<String> dataSourceDropdownValues =
      AddNewAssetScreen.stockDataSourcesList;
  String assetType = "stock";
  String currentAssetName = "GameStop";
  int assetSelection = 0;
  String currentDataSourceLabel = "Enter quantity manually:";

  // This helper function chooses the correct data source list, which is a
  //hardcoded constant above
  List<String> dataSourcesListByAssetType() {
    if (assetType == "crypto") {
      return AddNewAssetScreen.cryptoDataSourcesList;
    }
    if (assetType == "nft") {
      return AddNewAssetScreen.nftDataSourcesList;
    }
    if (assetType == "cash") {
      return AddNewAssetScreen.cashDataSourcesList;
    }
    return AddNewAssetScreen.stockDataSourcesList;
  }

  // This is used by the AssetType CupertinoSegmentedSelection widget as a
  //callback function to update all the fields to reflect a change in the asset
  //type (i.e. stocks, crypto, nfts, cash)
  void assetTypeChanged(int currentAssetSelection) {
    setState(
      () {
        assetSelection = currentAssetSelection;
        determineAssetTypeFromSelection(assetSelection);
        dataSourceDropdownValues = dataSourcesListByAssetType();
        currentDataSource = dataSourceDropdownValues.first;
        // TODO make currentAssetName remember the last asset selected from a category after changing
        currentAssetName = APIService(assetType).getAssetList().first;
        dataSourceChanged(currentDataSource);
      },
    );
  }

  // This translates an int into a word for the purposes of the AssetTypeSelection widget's legibility
  void determineAssetTypeFromSelection(int assetSelection) {
    if (assetSelection == 0) {
      assetType = "stock";
    }
    if (assetSelection == 1) {
      assetType = "crypto";
    }
    if (assetSelection == 2) {
      assetType = "nft";
    }
    if (assetSelection == 3) {
      assetType = "cash";
    }
  }

  // This is called by the DataSourceDropdown's callback function to update
  // the current data source and label in the other widgets
  void dataSourceChanged(String dataSource) {
    setState(() {
      currentDataSource = dataSource;
      currentDataSourceLabel = getDataSourceLabel();
      //TODO implement broker and exchange API support, then check if the source is an API, then ask which supported exchange or broker they wish to use
    });
  }

  // This is called by the callback function that triggers when the dropdown
  //corresponding to specific securities (AssetDropdown) is changed.
  void assetDropdownChanged(String currentAssetName) {
    setState(() {
      this.currentAssetName = currentAssetName;
    });
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
    if (currentDataSource.endsWith("Qty")) {
      return "Enter quantity manually: ";
    }
    return "Enter quantity manually: ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                assetSelection: assetSelection,
                assetTypeChangedCallback: assetTypeChanged),
            DataSourceDropdown(
                currentDataSource: currentDataSource,
                dataSourceDropdownValues: dataSourceDropdownValues,
                dataSourceChangedCallback: dataSourceChanged),
            AssetDropdown(
                currentAssetName: currentAssetName,
                assetType: assetType,
                assetDropdownChangedCallback: assetDropdownChanged),
            DataSourceLabel(
              dataSourceLabel: currentDataSourceLabel,
            ),
            const AcceptCancelButton(),
          ],
        ),
      ),
    );
  }
}

// This is the rounded selection widget at the top labelled "Stocks Crypto NFTs Cash"
class AssetCategorySelection extends StatefulWidget {
  final int assetSelection;
  final ValueChanged<int> assetTypeChangedCallback;
  const AssetCategorySelection(
      {super.key,
      required this.assetSelection,
      required this.assetTypeChangedCallback});
  @override
  State<AssetCategorySelection> createState() => _AssetCategorySelectionState();
}

class _AssetCategorySelectionState extends State<AssetCategorySelection> {
  int _assetSelection = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
            2: Text('NFTs', style: TextStyle(color: Colors.white)),
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
        focusColor: Colors.black,
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
        dropdownColor: Colors.black,
      ),
    );
  }
}

// This dropdown allows the user to specify a security to track
class AssetDropdown extends StatelessWidget {
  final String assetType;
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        focusColor: Colors.black,
        onChanged: ((String? chosenAssetName) {
          assetDropdownChangedCallback(chosenAssetName!);
        }),
        value: currentAssetName,
        items:
            APIService(assetType).getAssetList().map<DropdownMenuItem<String>>(
          (String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          },
        ).toList(),
        isExpanded: true,
        style: const TextStyle(color: Colors.white),
        dropdownColor: Colors.black,
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

// This specifies whether user intends to back out, or accept the settings
// and begin tracking the newly described asset
class AcceptCancelButton extends StatefulWidget {
  const AcceptCancelButton({super.key});

  @override
  State<AcceptCancelButton> createState() => _AcceptCancelButtonState();
}

class _AcceptCancelButtonState extends State<AcceptCancelButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAccept,
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.black87),
                      foregroundColor:
                          MaterialStatePropertyAll<Color>(Colors.white70),
                    ),
                    child: const Text(
                      "Accept",
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.black38),
                      foregroundColor:
                          MaterialStatePropertyAll<Color>(Colors.white70),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onAccept() {}

  void onCancel() {
    Navigator.pop(context);
  }
}
