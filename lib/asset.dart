import 'api_service.dart';

enum AssetType { stock, crypto, nft, cash }

abstract class Asset {
  String? name;
  String? ticker;

  double? getPrice();
  double? getValue();
  String? getNameFromTicker(String ticker);
}

class Crypto implements Asset {
  @override
  String? name;

  @override
  String? ticker;
  double? quantity;

  Crypto(String this.ticker, double this.quantity) {
    name = getNameFromTicker(ticker!);
  }
  Crypto.byWalletAddress(String this.ticker, String address) {
    name = getNameFromTicker(ticker!);
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
  String getNameFromTicker(String ticker) {
    throw UnimplementedError();
  }

  double? getQuantityByAddress(String address) {
    return null;
  }
}
