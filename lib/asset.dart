import 'api_service.dart';

enum AssetType { stock, crypto, nft, cash }

abstract class Asset {
  String? name;
  String? ticker;

  double? getPrice();
  double? getValue();
  String? getNameFromTicker();
}

class Crypto implements Asset {
  @override
  String? name;

  @override
  String? ticker;
  double? quantity;

  Crypto(String this.ticker, double this.quantity) {
    name = getNameFromTicker();
  }
  Crypto.byWalletAddress(String this.ticker, String address) {
    name = getNameFromTicker();
    quantity = getQuantityByAddress(address);
  }

  @override
  double? getPrice() {
    return AssetDataAPI(AssetType.crypto).getPrice(ticker!);
  }

  @override
  double getValue() {
    return (getPrice()! * quantity!);
  }

  @override
  String getNameFromTicker() {
    throw UnimplementedError();
  }

  double? getQuantityByAddress(String address) {
    return null;
  }
}
