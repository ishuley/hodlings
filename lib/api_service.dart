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
      for (var cryptoDetails in result.data) {
        cryptoNameAndTickerList.add({cryptoDetails.symbol: cryptoDetails.name});
      }
      return cryptoNameAndTickerList;
    } else {
      return [];
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
        {"access_key": stockDataApiKey, "limit": "10000"});

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
      return [];
    }
  }

  double getPrice(String ticker) {
    return 2.0;
  }
}

class CashAPI {
  final currencyApiUrl = "api.apilayer.com";

  Future<List> getAssetNamesAndTickers() async {
    var url = Uri.https(currencyApiUrl, "/currency_data/list",
        {"apikey": currencyExchangeDataApiKey});
    var response = await get(url);
    if (response.statusCode == 200) {
      List<Map<String, String>> currencyNamesAndTickers = [];

      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (jsonResponse['success'] == true) {
        Map<String, dynamic> currencyList = jsonResponse['currencies'];
        currencyList.forEach((key, value) {
          currencyNamesAndTickers.add({key: value});
        });
      }
      return currencyNamesAndTickers;
    } else {
      return [];
    }
  }

  double getPrice(String ticker) {
    return 1.0;
  }
}
