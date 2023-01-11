import 'package:flutter/material.dart';
import 'package:hodlings/asset.dart';
import 'package:search_choices/search_choices.dart';

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
      assetNameDropdownItemsList.add(
        DropdownMenuItem(
          value: tickerAndNameString,
          child: Text(tickerAndNameString),
        ),
      );
    }
    return assetNameDropdownItemsList;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      child: SearchChoices.single(
        searchInputDecoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).iconTheme.color!,
              width: 0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).iconTheme.color!,
              width: 0,
            ),
          ),
        ),
        menuBackgroundColor: Theme.of(context).primaryColor,
        items: mapListForDropdown(),
        value: currentAssetName,
        hint: Text(
          currentAssetName,
        ),
        searchHint: const Text(
          'Select asset',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        closeButton: TextButton(
          onPressed: (() => {
                Navigator.pop(context),
              }),
          style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.all(Theme.of(context).iconTheme.color),
          ),
          child: const Text(
            'Close',
            style: TextStyle(fontSize: 16),
          ),
        ),
        onChanged: ((String? chosenAssetName) {
          assetDropdownChangedCallback(chosenAssetName!);
        }),
        isExpanded: true,
        displayClearIcon: false,
        style: TextStyle(
          backgroundColor: Theme.of(context).primaryColor,
          color: Theme.of(context).textTheme.labelLarge?.color,
        ),
      ),
    );
  }
}
