import 'dart:convert';
import 'dart:io';
import 'package:hodlings/main_screen/asset.dart';
import 'package:hodlings/main_screen/asset_card.dart';
import 'package:hodlings/persistence/asset_card_item.dart';
import 'package:path_provider/path_provider.dart';

class AssetCardListStorage {
  Future<String> get _applicationSupportPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> get _assetCardsFile async {
    final path = await _applicationSupportPath;
    return File('$path/assetCards.json');
  }

  Future<List<AssetCard>> readAssetCardsData() async {
    File assetCardsFile = await _assetCardsFile;
    List<AssetCard> assetCardsList = [];
    if (await assetCardsFile.exists()) {
      String encodedAssetCardsData = await assetCardsFile.readAsString();
      List<dynamic> decodedAssetCardsData = jsonDecode(encodedAssetCardsData);
      List<AssetCardItem> assetCardItemList = [];
      for (Map<String, dynamic> assetCardItem in decodedAssetCardsData) {
        assetCardItemList.add(AssetCardItem.fromJson(assetCardItem));
      }
      for (AssetCardItem assetCardItem in assetCardItemList) {
        assetCardsList.add(await assetCardItem.getAssetCard());
      }
    }
    return assetCardsList;
  }

  Future<void> writeAssetCardsData(List<AssetCard> assetCardList) async {
    List<AssetCardItem> assetCardItemList = [];

    for (AssetCard assetCard in assetCardList) {
      AssetCardItem assetCardItem = AssetCardItem(
        assetCard.asset.assetType.asString!,
        assetCard.asset.assetFieldData,
        assetCard.asset.assetId,
        assetCard.asset.dataSource,
        assetCard.asset.dataSourceField,
        assetCard.vsTicker,
        assetCard.marketCapString,
        // assetCard.extendedHoursPrice,
      );

      assetCardItemList.add(assetCardItem);
    }
    String encodedAssetCardItemList = jsonEncode(assetCardItemList);

    File assetCardsFile = await _assetCardsFile;

    await assetCardsFile.writeAsString(encodedAssetCardItemList);
  }

  Future<void> deleteAssetCardsFile() async {
    File assetCardsFile = await _assetCardsFile;
    if (await assetCardsFile.exists()) {
      await assetCardsFile.delete();
    }
  }
}
