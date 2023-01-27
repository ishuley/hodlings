import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          backgroundColor: Theme.of(context).primaryColor,
          groupValue: _assetSelection,
          onValueChanged: (int? choice) {
            widget.assetTypeChangedCallback(choice!);
            setState(() {
              _assetSelection = choice;
            });
          },
          children: const {
            0: Text('Stocks'),
            1: Text('Crypto'),
            2: Text('Cash'),
            // 3: Text('NFT'),
          },
        ),
      ),
    );
  }
}
