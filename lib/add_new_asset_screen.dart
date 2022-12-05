import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

const List<String> stockList = <String>[
  'Manual Qty',
  'Transfer Agent',
  'Broker API'
];
const List<String> cryptoList = <String>[
  'Blockchain address',
  'Exchange API',
  'Manual Qty'
];
const List<String> nftList = <String>['Blockchain Address', 'Manual qty'];

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
            child: Column(children: [
              assetTypeSelection(),
              dataSourcesDropdown(),
              acceptCancelButtons()
            ])));
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

  int _assetSelection = 0;

  String currentValue = stockList.first;
  List<String> dropDownValue = stockList;

  Padding assetTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: CupertinoSlidingSegmentedControl(
        groupValue: _assetSelection,
        onValueChanged: (int? choice) {
          setState(() {
            _assetSelection = choice!;
            if (_assetSelection == 0) {
              dropDownValue = stockList;
            }
            if (_assetSelection == 1) {
              dropDownValue = cryptoList;
            }
            if (_assetSelection == 2) {
              dropDownValue = nftList;
            }
          });
        },
        backgroundColor: Colors.black38,
        thumbColor: Colors.black,
        children: const {
          0: Text('Stocks', style: TextStyle(color: Colors.white)),
          1: Text('Crypto', style: TextStyle(color: Colors.white)),
          2: Text('NFTs', style: TextStyle(color: Colors.white)),
        },
      )),
    );
  }

  Padding dataSourcesDropdown() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          focusColor: Colors.black,
          value: dropDownValue.first,
          onChanged: ((String? newValue) {
            setState(() {
              newValue = dropDownValue.first;
            });
          }),
          items: dropDownValue.map<DropdownMenuItem<String>>((String value) {
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

  void onAccept() {}

  void onCancel() {
    Navigator.pop(context);
  }
}
