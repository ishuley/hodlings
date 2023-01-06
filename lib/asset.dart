import 'api_service.dart';

enum AssetType { stock, crypto, cash }

abstract class Asset {
  final String assetFieldData;
  late String name;
  late String ticker;
  late AssetType assetType;
  late String assetID;

  Asset({required this.assetFieldData, required this.assetID}) {
    List splitAssetFieldData = assetFieldData.split(" - ");
    ticker = splitAssetFieldData.elementAt(0);
    name = splitAssetFieldData.elementAt(1);
  }

  double quantity = 0;
  Future<double> getPrice({String vsTicker = 'usd'}) async {
    return await AssetAPI(assetType).getPrice(id: assetID, vsTicker: vsTicker);
  }

  Future<double> getMarketCap({String vsTicker = 'usd'}) async {
    return await AssetAPI(assetType)
        .getMarketCap(id: assetID, vsTicker: vsTicker);
  }
}

class Crypto extends Asset {
  Crypto(
      {required super.assetFieldData,
      required super.assetID,
      required double qty}) {
    assetType = AssetType.crypto;
    quantity = qty;
  }
  Crypto.byAddress(
      {required super.assetFieldData,
      required super.assetID,
      required String address}) {
    assetType = AssetType.crypto;
    quantity = getQuantityFromBlockchainAddress(address);
  }

  double getQuantityFromBlockchainAddress(String address) {
    return 2.0;
  }
}

class Stock extends Asset {
  Stock(
      {required super.assetFieldData,
      required super.assetID,
      required double qty}) {
    quantity = qty;
    assetType = AssetType.stock;
  }
}

class Cash extends Asset {
  Cash(
      {required super.assetFieldData,
      required super.assetID,
      required double qty}) {
    quantity = qty;
    assetType = AssetType.cash;
  }
}
