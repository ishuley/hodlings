import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'api_service.dart';

const List<String> stockDataSourcesList = <String>[
  'Manual Qty',
  'Transfer Agent',
  'Broker API',
];
const List<String> cryptoDataSourcesList = <String>[
  'Blockchain Address',
  'Exchange API',
  'Manual Qty',
];
const List<String> nftDataSourcesList = <String>[
  'Blockchain Address',
  'Manual Qty',
];
const List<String> cashDataSourcesList = <String>[
  'Manual Qty',
];

String _currentDataSource = stockDataSourcesList.first;
List<String> dataSourceDropdownValuesList = stockDataSourcesList;
String _assetType = "stock";
String _currentAssetName = "GameStop";
int _assetSelection = 0;

class AddNewAssetScreen extends StatefulWidget {
  const AddNewAssetScreen({super.key});

  @override
  State<AddNewAssetScreen> createState() => _AddNewAssetScreenState();
}

class _AddNewAssetScreenState extends State<AddNewAssetScreen> {
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
            child: Column(children: const [
              AssetTypeSelection(),
              DataSourceDropdown(),
              AssetDropdown(),
              DataSourceLabel(),
              AcceptCancelButton(),
            ])));
  }
}

class AssetTypeSelection extends StatefulWidget {
  const AssetTypeSelection({super.key});

  @override
  State<AssetTypeSelection> createState() => _AssetTypeSelectionState();
}

class _AssetTypeSelectionState extends State<AssetTypeSelection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: CupertinoSlidingSegmentedControl(
        groupValue: _assetSelection,
        onValueChanged: (int? choice) {
          setState(() {
            _assetSelection = choice!;
            if (_assetSelection == 0) {
              dataSourceDropdownValuesList = stockDataSourcesList;
              _currentDataSource = stockDataSourcesList.first;
              _assetType = "stock";
            }
            if (_assetSelection == 1) {
              dataSourceDropdownValuesList = cryptoDataSourcesList;
              _currentDataSource = cryptoDataSourcesList.first;
              _assetType = "crypto";
            }
            if (_assetSelection == 2) {
              dataSourceDropdownValuesList = nftDataSourcesList;
              _currentDataSource = nftDataSourcesList.first;
              _assetType = "nft";
            }
            if (_assetSelection == 3) {
              dataSourceDropdownValuesList = cashDataSourcesList;
              _currentDataSource = cashDataSourcesList.first;
              _assetType = "cash";
            }
            _currentAssetName = APIService(_assetType).getAssetList().first;
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

class DataSourceDropdown extends StatefulWidget {
  const DataSourceDropdown({super.key});

  @override
  State<DataSourceDropdown> createState() => _DataSourceDropdownState();
}

class _DataSourceDropdownState extends State<DataSourceDropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          focusColor: Colors.black,
          onChanged: ((String? newValue) {
            setState(() {
              _currentDataSource = newValue!;
            });
          }),
          value: _currentDataSource,
          items: dataSourceDropdownValuesList
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

class AssetDropdown extends StatefulWidget {
  const AssetDropdown({super.key});

  @override
  State<AssetDropdown> createState() => _AssetDropdownState();
}

class _AssetDropdownState extends State<AssetDropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          focusColor: Colors.black,
          onChanged: ((String? newValue) {
            setState(() {
              _currentAssetName = newValue!;
            });
          }),
          value: _currentAssetName,
          items: APIService(_assetType)
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

class DataSourceLabel extends StatefulWidget {
  const DataSourceLabel({super.key});

  @override
  State<DataSourceLabel> createState() => _DataSourceLabelState();
}

class _DataSourceLabelState extends State<DataSourceLabel> {
  @override
  Widget build(BuildContext context) {
    if (_currentDataSource.endsWith("API")) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text("Read-only API Key: ",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }
    if (_currentDataSource.endsWith("Address")) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text("Blockchain address: ",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text("Enter quantity manually: ",
            style: TextStyle(color: Colors.white)),
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
