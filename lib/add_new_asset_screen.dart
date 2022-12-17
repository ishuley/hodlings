import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'api_service.dart';

class AddNewAssetScreen extends StatefulWidget {
  const AddNewAssetScreen({super.key});

  static const List<String> stockDataSourcesList = <String>[
    'Manual Qty',
    'Transfer Agent',
    'Broker API',
  ];
  static const List<String> cryptoDataSourcesList = <String>[
    'Blockchain Address',
    'Exchange API',
    'Manual Qty',
  ];
  static const List<String> nftDataSourcesList = <String>[
    'Blockchain Address',
    'Manual Qty',
  ];
  static const List<String> cashDataSourcesList = <String>[
    'Manual Qty',
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

  assetTypeChanged(int currentAssetSelection) {
    setState(() {
      assetSelection = currentAssetSelection;
      determineAssetTypeFromSelection(assetSelection);
      dataSourceDropdownValues = dataSourcesListByAssetType();
      currentDataSource = dataSourceDropdownValues.first;
      // TODO make currentAssetName remember the last asset selected from a category after changing
      currentAssetName = APIService(assetType).getAssetList().first;
      dataSourceChanged(currentDataSource);
    });
  }

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

  dataSourceChanged(String dataSource) {
    setState(() {
      currentDataSource = dataSource;
      currentDataSourceLabel = getDataSourceLabel();
      //TODO implement broker and exchange API support, then check if the source is an API, then ask which supported exchange or broker they wish to use
    });
  }

  assetDropdownChanged(String currentAssetName) {
    setState(() {
      this.currentAssetName = currentAssetName;
    });
  }

  String getDataSourceLabel() {
    if (currentDataSource.endsWith("API")) {
      return "Enter Read-Only API Key: ";
    }
    if (currentDataSource.endsWith("Address")) {
      return "Enter blockchain address: ";
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
            child: Column(children: [
              AssetTypeSelection(
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
            ])));
  }
}

class AssetTypeSelection extends StatefulWidget {
  final int assetSelection;
  final ValueChanged<int> assetTypeChangedCallback;
  const AssetTypeSelection(
      {super.key,
      required this.assetSelection,
      required this.assetTypeChangedCallback});
  @override
  State<AssetTypeSelection> createState() => _AssetTypeSelectionState();
}

class _AssetTypeSelectionState extends State<AssetTypeSelection> {
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
      )),
    );
  }
}

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
        ));
  }
}

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
          items: APIService(assetType)
              .getAssetList()
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          dropdownColor: Colors.black,
        ));
  }
}

class DataSourceLabel extends StatelessWidget {
  const DataSourceLabel({super.key, required this.dataSourceLabel});

  final String dataSourceLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child:
            Text(dataSourceLabel, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

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
                    )),
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
              )),
            ],
          ),
        ],
      )),
    );
  }

  void onAccept() {}

  void onCancel() {
    Navigator.pop(context);
  }
}
