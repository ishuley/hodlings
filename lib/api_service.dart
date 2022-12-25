import 'dart:io';

import 'asset.dart';
import 'package:coingecko_api/coingecko_api.dart';

class AssetDataAPI {
  AssetType assetType;
  AssetDataAPI(this.assetType);

  Future<List> getAssetNamesList() {
    if (assetType == AssetType.crypto) {
      return CryptoAPI().getAssetNamesList();
    }
    if (assetType == AssetType.cash) {
      return CashAPI().getAssetNamesList();
    }
    return StockAPI().getAssetNamesList();
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
  Future<List<String>> getAssetNamesList() async {
    final api = CoinGeckoApi();
    final result = await api.coins.listCoins(includePlatforms: true);
    if (!result.isError) {
      List<String> nameList = [];
      for (var coinDetailsElement in result.data) {
        nameList.add(coinDetailsElement.name);
      }
      return nameList;
    } else {
      throw const HttpException("Couldn't retrieve asset list from CoinGecko");
    }
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
  Future<List> getAssetNamesList() {
    throw UnimplementedError();
  }

  double getPrice(String ticker) {
    return 2.0;
  }
}

class CashAPI {
  Future<List> getAssetNamesList() {
    throw UnimplementedError();
  }

  double getPrice(String ticker) {
    return 2.0;
  }
}
