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

class AddNewAssetScreen extends StatefulWidget {
  const AddNewAssetScreen({super.key});

  @override
  State<AddNewAssetScreen> createState() => _AddNewAssetScreenState();
}

String currentDataSource = stockDataSourcesList.first;
List<String> dataSourceDropdownValuesList = stockDataSourcesList;

String assetType = "stock";
String _currentAssetName = "GameStop";

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
            child: Column(children: [
              assetTypeSelection(),
              dataSourcesDropdown(),
              chooseAssetDropdown(),
              acceptCancelButtons(),
            ])));
  }

  int _assetSelection = 0;

  Padding assetTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: CupertinoSlidingSegmentedControl(
        groupValue: _assetSelection,
        onValueChanged: (int? choice) {
          setState(() {
            _assetSelection = choice!;
            setDropdownsBasedOnAssetSelection();
            _currentAssetName = APIService(assetType).getAssetList().first;
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

  void setDropdownsBasedOnAssetSelection() {
    if (_assetSelection == 0) {
      setDropdownsToStock();
    }
    if (_assetSelection == 1) {
      setDropdownsToCrypto();
    }
    if (_assetSelection == 2) {
      setDropdownsToNFT();
    }
    if (_assetSelection == 3) {
      setDropdownsToCash();
    }
  }

  void setDropdownsToCash() {
    dataSourceDropdownValuesList = cashDataSourcesList;
    currentDataSource = cashDataSourcesList.first;
    assetType = "cash";
  }

  void setDropdownsToNFT() {
    dataSourceDropdownValuesList = nftDataSourcesList;
    currentDataSource = nftDataSourcesList.first;
    assetType = "nft";
  }

  void setDropdownsToCrypto() {
    dataSourceDropdownValuesList = cryptoDataSourcesList;
    currentDataSource = cryptoDataSourcesList.first;
    assetType = "crypto";
  }

  void setDropdownsToStock() {
    dataSourceDropdownValuesList = stockDataSourcesList;
    currentDataSource = stockDataSourcesList.first;
    assetType = "stock";
  }

  Padding dataSourcesDropdown() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          focusColor: Colors.black,
          onChanged: ((String? newValue) {
            setState(() {
              currentDataSource = newValue!;
            });
          }),
          value: currentDataSource,
          items: dataSourceDropdownValuesList
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

  Padding chooseAssetDropdown() {
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

  Expanded acceptCancelButtons() {
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
