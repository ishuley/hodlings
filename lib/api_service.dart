import 'asset.dart';

class AssetDataAPI {
  AssetType assetType;
  AssetDataAPI(this.assetType);

  List<String> getAssetList() {
    if (assetType == AssetType.crypto) {
      return CryptoAPI().getAssetList();
    }
    if (assetType == AssetType.cash) {
      return CashAPI().getAssetList();
    }
    return StockAPI().getAssetList();
  }

  double? getPrice(String ticker) {
    if (assetType == AssetType.crypto) {
      return CryptoAPI().getPrice(ticker);
    }
    if (assetType == AssetType.cash) {
      return CashAPI().getPrice(ticker);
    }
    return StockAPI().getPrice(ticker);
  }
}

class CryptoAPI {
  List<String> getAssetList() {
    return [
      "Ethereum",
      "Monero",
      "Bitcoin Cash",
    ];
  }

  double getPrice(String ticker) {
    return 2.0;
  }

  String getName(String ticker) {
    return "Ethereum";
  }
}

class StockAPI {
  List<String> getAssetList() {
    return [
      "GameStop",
      "Other Stock",
    ];
  }

  double getPrice(String ticker) {
    return 2.0;
  }
}

class CashAPI {
  List<String> getAssetList() {
    return [
      "United States Dollar",
      "Euro",
      "Georgian Lari",
    ];
  }

  double getPrice(String ticker) {
    return 2.0;
  }
}
