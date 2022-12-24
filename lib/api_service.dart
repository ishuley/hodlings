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

  double? getPrice(String name) {
    if (assetType == AssetType.crypto) {
      return CryptoAPI().getPrice(name);
    }
    if (assetType == AssetType.cash) {
      return CashAPI().getPrice(name);
    }
    return StockAPI().getPrice(name);
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

  String getName() {
    return "Ethereum";
  }

  String getTicker() {
    return "ETH";
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
