import 'api_service.dart';

enum AssetType {
  stock(Stock.new),
  crypto(Crypto.new),
  cash(Cash.new);

  final Asset Function({
    required String assetFieldData,
    required String assetID,
    required String dataSource,
    required String dataSourceField,
  }) createAsset;
  const AssetType(this.createAsset);
}

abstract class Asset {
  final String assetFieldData;
  late final String name;
  late final String ticker;
  late final AssetType assetType;
  late final String assetID;
  final String dataSource;
  final String dataSourceField;
  late final double quantity;

  Asset({
    required this.assetFieldData,
    required this.assetID,
    required this.dataSource,
    required this.dataSourceField,
  }) {
    List<String> splitAssetFieldData = assetFieldData.split(' ');
    ticker = splitAssetFieldData.elementAt(0).toUpperCase();
    splitAssetFieldData.removeAt(0);
    name = splitAssetFieldData.join(' ');
  }

  Future<double> getPrice({String vsTicker = 'usd'}) async {
    return await AssetAPI(assetType).getPrice(id: assetID, vsTicker: vsTicker);
  }

  Future<double> getMarketCap({String vsTicker = 'usd'}) async {
    return await AssetAPI(assetType)
        .getMarketCap(id: assetID, vsTicker: vsTicker);
  }
}

class Crypto extends Asset {
  late final String? address;
  Crypto({
    required super.assetFieldData,
    required super.assetID,
    required super.dataSource,
    required super.dataSourceField,
  }) {
    if (dataSource.endsWith('Qty')) {
      quantity = double.parse(dataSourceField);
    }
    if (dataSource.endsWith('Address')) {
      address = dataSourceField;
      quantity = getQuantityFromBlockchainAddress(address!);
    }
    assetType = AssetType.crypto;
  }

  double getQuantityFromBlockchainAddress(String address) {
    return 2.0;
  }
}

class Stock extends Asset {
  Stock({
    required super.assetFieldData,
    required super.assetID,
    required super.dataSource,
    required super.dataSourceField,
  }) {
    if (dataSource.endsWith('Qty')) {
      quantity = double.parse(dataSourceField);
    }
    assetType = AssetType.stock;
  }
}

class Cash extends Asset {
  Cash({
    required super.assetFieldData,
    required super.assetID,
    required super.dataSource,
    required super.dataSourceField,
  }) {
    if (dataSource.endsWith('Qty')) {
      quantity = double.parse(dataSourceField);
    }
    assetType = AssetType.cash;
  }
}
