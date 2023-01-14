import 'package:hodlings/asset.dart';
import 'package:hodlings/asset_card.dart';

class AssetCardItem {
  final String assetFieldData;
  final String assetType;
  final String assetID;
  final String dataSource;
  final String dataSourceField;
  final String vsTicker;
  final String marketCapString;

  AssetCardItem(
    this.assetType,
    this.assetFieldData,
    this.assetID,
    this.dataSource,
    this.dataSourceField,
    this.vsTicker,
    this.marketCapString,
  );

  factory AssetCardItem.fromJson(
    Map<String, dynamic> jsonDecodedAsset,
  ) {
    return AssetCardItem(
      jsonDecodedAsset['assetType']!,
      jsonDecodedAsset['assetFieldData']!,
      jsonDecodedAsset['assetID']!,
      jsonDecodedAsset['dataSource']!,
      jsonDecodedAsset['dataSourceField']!,
      jsonDecodedAsset['vsTicker']!,
      jsonDecodedAsset['marketCapString']!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetType': assetType,
      'assetFieldData': assetFieldData,
      'assetID': assetID,
      'dataSource': dataSource,
      'dataSourceField': dataSourceField,
      'vsTicker': vsTicker,
      'marketCapString': marketCapString,
    };
  }

  Future<AssetCard> getAssetCard() async {
    AssetType assetTypeEnum = getEnumFromString()!;
    Asset asset = assetTypeEnum.createAsset(
      assetFieldData: assetFieldData,
      assetID: assetID,
      dataSource: dataSource,
      dataSourceField: dataSourceField,
    );
    return AssetCard(
      asset: asset,
      vsTicker: vsTicker,
      price: await asset.getPrice(),
      marketCapString: marketCapString,
    );
  }

  AssetType? getEnumFromString() {
    switch (assetType) {
      case 'stock':
        return AssetType.stock;
      case 'crypto':
        return AssetType.crypto;
      case 'cash':
        return AssetType.cash;
      default:
        return null;
    }
  }
}
