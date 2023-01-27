import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodlings/add_new_asset_screen/add_new_asset_screen.dart';
import 'package:hodlings/main_screen/asset_display/asset_card.dart';
import 'package:hodlings/main_screen/asset_display/asset_card_list_notifier.dart';

class AddNewAssetButton extends ConsumerStatefulWidget {
  const AddNewAssetButton({super.key});

  @override
  ConsumerState<AddNewAssetButton> createState() => _AddNewAssetButtonState();
}

class _AddNewAssetButtonState extends ConsumerState<AddNewAssetButton> {
  Future<void> _addNewAssetScreen() async {
    AssetCard? newAssetCard = await _getNewAssetCardFromAddNewAssetCardScreen();
    if (newAssetCard != null) {
      ref
          .read(assetCardsListNotifierProvider.notifier)
          .addNewAssetCard(newAssetCard);
    }
  }

  Future<AssetCard?> _getNewAssetCardFromAddNewAssetCardScreen() async {
    final AssetCard? newAssetCard = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewAssetScreen(),
      ),
    );
    return newAssetCard;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 75,
              child: TextButton(
                onPressed: _addNewAssetScreen,
                child: Icon(
                  Icons.add,
                  size: Theme.of(context).iconTheme.size,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
