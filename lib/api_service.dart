// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';
import 'asset.dart';
import 'package:coingecko_api/coingecko_api.dart';
import 'package:http/http.dart';
import 'api_keys.dart';

class AssetDataAPI {
  AssetType assetType;
  AssetDataAPI(this.assetType);

  Future<List> getAssetNamesAndTickersList() {
    if (assetType == AssetType.crypto) {
      return CryptoAPI().getAssetNamesAndTickers();
    }
    if (assetType == AssetType.cash) {
      return CashAPI().getAssetNamesAndTickers();
    }
    return StockAPI().getAssetNamesAndTickers();
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
  Future<List<Map<String, String>>> getAssetNamesAndTickers() async {
    final api = CoinGeckoApi();
    final result = await api.coins.listCoins(includePlatforms: true);
    if (!result.isError) {
      List<Map<String, String>> cryptoNameAndTickerList = [];
      for (var coinDetailsElement in result.data) {
        cryptoNameAndTickerList
            .add({coinDetailsElement.symbol: coinDetailsElement.name});
      }
      return cryptoNameAndTickerList;
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
  final stockApiUrl = "api.marketstack.com";

  Future<List<Map<String, String>>> getAssetNamesAndTickers() async {
    var url = Uri.http(stockApiUrl, "/v1/tickers",
        {"access_key": marketStackApiKey, "limit": "10000"});

    var response = await get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      List<Map<String, String>> stockNamesAndTickers = [];
      jsonResponse.forEach(
        (key, value) {
          if (key == 'data') {
            for (var stockData in value) {
              if (stockData['symbol'] != null && stockData['name'] != null) {
                stockNamesAndTickers.add(
                  {stockData['symbol']: stockData['name']},
                );
              }
            }
          }
        },
      );
      return stockNamesAndTickers;
    } else {
      throw const HttpException(
          "Couldn't retrieve asset list from MarketStack");
    }
  }

  double getPrice(String ticker) {
    return 2.0;
  }
}

class CashAPI {
  Future<List> getAssetNamesAndTickers() {
    throw UnimplementedError();
  }

  double getPrice(String ticker) {
    return 2.0;
  }
}
