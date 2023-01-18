import 'package:hodlings/main_screen/asset.dart';
import 'package:hodlings/main_screen/asset_card.dart';

class AssetCardItem {
  final String assetFieldData;
  final String assetType;
  final String assetId;
  final String dataSource;
  final String dataSourceField;
  final String vsTicker;
  final String marketCapString;
  final double extendedHoursPrice;

  AssetCardItem(
    this.assetType,
    this.assetFieldData,
    this.assetId,
    this.dataSource,
    this.dataSourceField,
    this.vsTicker,
    this.marketCapString,
    this.extendedHoursPrice,
  );

  factory AssetCardItem.fromJson(
    Map<String, dynamic> jsonDecodedAsset,
  ) {
    return AssetCardItem(
      jsonDecodedAsset['assetType']!,
      jsonDecodedAsset['assetFieldData']!,
      jsonDecodedAsset['assetId']!,
      jsonDecodedAsset['dataSource']!,
      jsonDecodedAsset['dataSourceField']!,
      jsonDecodedAsset['vsTicker']!,
      jsonDecodedAsset['marketCapString']!,
      jsonDecodedAsset['extendedHoursPrice']!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetType': assetType,
      'assetFieldData': assetFieldData,
      'assetId': assetId,
      'dataSource': dataSource,
      'dataSourceField': dataSourceField,
      'vsTicker': vsTicker,
      'marketCapString': marketCapString,
      'extendedHoursPrice': extendedHoursPrice,
    };
  }

  Future<AssetCard> getAssetCard() async {
    AssetType assetTypeEnum = getEnumFromString()!;
    Asset asset = assetTypeEnum.createAsset(
      assetFieldData: assetFieldData,
      assetId: assetId,
      dataSource: dataSource,
      dataSourceField: dataSourceField,
    );
    return AssetCard(
      asset: asset,
      vsTicker: vsTicker,
      price: await asset.getPrice(),
      marketCapString: marketCapString,
      extendedHoursPrice: extendedHoursPrice,
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
