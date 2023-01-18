import 'package:hodlings/api_service/api_service.dart';
import 'package:intl/intl.dart';

enum AssetType {
  stock(Stock.new),
  crypto(Crypto.new),
  cash(Cash.new);

  final Asset Function({
    required String assetFieldData,
    required String assetId,
    required String dataSource,
    required String dataSourceField,
  }) createAsset;
  const AssetType(this.createAsset);
}

extension AssetTypeString on AssetType {
  String? get asString {
    switch (this) {
      case AssetType.stock:
        return 'stock';
      case AssetType.crypto:
        return 'crypto';
      case AssetType.cash:
        return 'cash';
      default:
        return null;
    }
  }
}

abstract class Asset {
  final String assetFieldData;
  late final AssetType assetType;
  late final String assetId;
  final String dataSource;
  String dataSourceField;
  late final String name;
  late final String ticker;
  late double quantity;
  late double marketCap;

  Asset({
    required this.assetFieldData,
    required this.assetId,
    required this.dataSource,
    required this.dataSourceField,
  }) {
    List<String> splitAssetFieldData = assetFieldData.split(' ');
    ticker = splitAssetFieldData.elementAt(0).toUpperCase();
    splitAssetFieldData.removeAt(0);
    name = splitAssetFieldData.join(' ');
  }

  Future<void> initMarketCap({String vsTicker = 'usd'}) async {
    marketCap = await getMarketCap(vsTicker: vsTicker);
  }

  Future<double> getPrice({String vsTicker = 'usd'}) async {
    return await AssetAPI(assetType).getPrice(id: assetId, vsTicker: vsTicker);
  }

  Future<double> getMarketCap({String vsTicker = 'usd'}) async {
    return await AssetAPI(assetType)
        .getMarketCap(id: assetId, vsTicker: vsTicker);
  }

  Future<String> getMarketCapString({String vsTicker = 'usd'}) async {
    marketCap = await getMarketCap(vsTicker: vsTicker);
    if (marketCap == 0) {
      return '';
    }
    String formattedMktCap = formatMarketCap(marketCap);
    String marketCapString =
        'Market Cap: $formattedMktCap ${vsTicker.toUpperCase()}';
    return marketCapString;
  }

  String formatMarketCap(double marketCap) {
    String formattedMktCap =
        NumberFormat('###,###,###,###,###,###,###.##', 'en_US')
            .format(marketCap);
    return formattedMktCap;
  }
}

class Crypto extends Asset {
  late final String? address;
  Crypto({
    required super.assetFieldData,
    required super.assetId,
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
    initMarketCap();
  }

  double getQuantityFromBlockchainAddress(String address) {
    return 2.0;
  }
}

class Stock extends Asset {
  Stock({
    required super.assetFieldData,
    required super.assetId,
    required super.dataSource,
    required super.dataSourceField,
  }) {
    if (dataSource.endsWith('Qty')) {
      quantity = double.parse(dataSourceField);
    }
    assetType = AssetType.stock;
    initMarketCap();
  }

  // Future<double> getExtendedHoursPrice() async {
  //   double extendedHoursPrice = 0;
  //   if (getExtendedHoursStatus() != MarketStatus.open) {
  //     extendedHoursPrice = await StockAPI().getExtendedHoursPrice(id: assetId);
  //     print(extendedHoursPrice);
  //   }
  //   return extendedHoursPrice;
  // }

  // MarketStatus getExtendedHoursStatus() {
  //   final currentTime = DateTime.now().toUtc();
  //   final premarketStart = DateTime.utc(
  //     currentTime.year,
  //     currentTime.month,
  //     currentTime.day,
  //     13,
  //     0,
  //   );
  //   final premarketEnd = DateTime.utc(
  //     currentTime.year,
  //     currentTime.month,
  //     currentTime.day,
  //     17,
  //     30,
  //   );
  //   final aftermarketStart = DateTime.utc(
  //     currentTime.year,
  //     currentTime.month,
  //     currentTime.day,
  //     21,
  //     0,
  //   );
  //   final aftermarketEnd = DateTime.utc(
  //     currentTime.year,
  //     currentTime.month,
  //     currentTime.day,
  //     1,
  //     0,
  //   );

  //   if (currentTime.isAfter(premarketStart) &&
  //       currentTime.isBefore(premarketEnd)) {
  //     return MarketStatus.premarket;
  //   }
  //   if (currentTime.isAfter(aftermarketStart) ||
  //       currentTime.isBefore(aftermarketEnd)) {
  //     return MarketStatus.afterhours;
  //   }
  //   if (currentTime.isAfter(premarketEnd) &&
  //       currentTime.isBefore(aftermarketStart)) {
  //     return MarketStatus.open;
  //   }

  //   return MarketStatus.closed;
  // }
}

class Cash extends Asset {
  Cash({
    required super.assetFieldData,
    required super.assetId,
    required super.dataSource,
    required super.dataSourceField,
  }) {
    if (dataSource.endsWith('Qty')) {
      quantity = double.parse(dataSourceField);
    }
    assetType = AssetType.cash;
    initMarketCap();
  }
}
