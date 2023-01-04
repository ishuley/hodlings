import 'dart:convert';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/coin_short.dart';
import 'package:coingecko_api/data/market.dart';
import 'asset.dart';
import 'package:coingecko_api/coingecko_api.dart';
import 'package:http/http.dart';
import 'api_keys.dart';

abstract class AssetAPI {
  late AssetType assetType;

  factory AssetAPI(AssetType assetType) {
    switch (assetType) {
      case AssetType.stock:
        return StockAPI();
      case AssetType.crypto:
        return CryptoAPI();
      case AssetType.cash:
        return CashAPI();
    }
  }
  Future<List<Map<String, String>>> getAssetNamesAndTickers();
  Future<double> getPrice({required String ticker, String vsTicker});
  Future<double> getMarketCap({required String ticker, String vsTicker});
}

class CryptoAPI implements AssetAPI {
  final api = CoinGeckoApi();

  @override
  late AssetType assetType;

  @override
  Future<List<Map<String, String>>> getAssetNamesAndTickers() async {
    final CoinGeckoResult<List<CoinShort>> result =
        await api.coins.listCoins(includePlatforms: true);
    if (!result.isError) {
      List<Map<String, String>> cryptoNameAndTickerList = [];
      for (CoinShort cryptoDetails in result.data) {
        cryptoNameAndTickerList.add({cryptoDetails.symbol: cryptoDetails.name});
      }
      return cryptoNameAndTickerList;
    }
    return [];
  }

  @override
  Future<double> getPrice(
      {required String ticker, String vsTicker = 'usd'}) async {
    ticker = ticker.toLowerCase();
    vsTicker = vsTicker.toLowerCase();
    CoinGeckoResult<List<Market>> marketData =
        await api.coins.listCoinMarkets(vsCurrency: vsTicker);
    for (Market market in marketData.data) {
      if (market.symbol == ticker) {
        return market.currentPrice!;
      }
    }
    return 0;
  }

  @override
  Future<double> getMarketCap(
      {required String ticker, String vsTicker = 'usd'}) async {
    ticker = ticker.toLowerCase();
    vsTicker = vsTicker.toLowerCase();
    CoinGeckoResult<List<Market>> marketData =
        await api.coins.listCoinMarkets(vsCurrency: vsTicker);
    for (Market market in marketData.data) {
      if (market.symbol == ticker) {
        return market.marketCap!;
      }
    }
    return 0;
  }
}

class StockAPI implements AssetAPI {
  @override
  late AssetType assetType;

  @override
  Future<List<Map<String, String>>> getAssetNamesAndTickers() async {
    Uri url = Uri.http(stockApiUrl, "/api/v3/stock/list",
        {"apikey": stockDataApiKey, "limit": "10000"});

    Response response = await get(url);
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonResponse =
          jsonDecode(response.body) as List<Map<String, dynamic>>;
      List<Map<String, String>> stockNamesAndTickers = [];
      for (Map<String, dynamic> stockDataMap in jsonResponse) {
        if (stockDataMap['symbol'] != null && stockDataMap['name'] != null) {
          stockNamesAndTickers.add(
            {stockDataMap['symbol']: stockDataMap['name']},
          );
        }
      }
      return stockNamesAndTickers;
    }
    return [];
  }

  @override
  Future<double> getPrice(
      {required String ticker, String vsTicker = 'USD'}) async {
    ticker = ticker.toUpperCase();
    vsTicker = vsTicker.toUpperCase();
    Uri url = Uri.http(stockApiUrl, "/api/v3/quote-short/",
        {"apikey": stockDataApiKey, "symbols": ticker});
    Response response = await get(url);
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonResponse =
          jsonDecode(response.body) as List<Map<String, dynamic>>;
      return jsonResponse[0]["price"];
    }
    return 0.0;
  }

  @override
  Future<double> getMarketCap(
      {required String ticker, String vsTicker = 'USD'}) async {
    ticker = ticker.toUpperCase();
    vsTicker = vsTicker.toUpperCase();

    Uri url = Uri.http(stockApiUrl, "/api/v3/market-capitalization/",
        {"apikey": stockDataApiKey, "symbols": ticker});
    Response response = await get(url);
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> jsonResponse =
          jsonDecode(response.body) as List<Map<String, dynamic>>;
      return jsonResponse[0]["marketCap"];
    }
    return 0.0;
  }
}

class CashAPI implements AssetAPI {
  @override
  late AssetType assetType;

  @override
  Future<List<Map<String, String>>> getAssetNamesAndTickers() async {
    Uri url = Uri.https(currencyApiUrl, "/exchangerates_data/symbols",
        {"apikey": currencyExchangeDataApiKey});
    Response response = await get(url);
    if (response.statusCode == 200) {
      List<Map<String, String>> currencyNamesAndTickers = [];

      Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (jsonResponse['success'] == true) {
        Map<String, dynamic> currencyList = jsonResponse['symbols'];
        currencyList.forEach((key, value) {
          currencyNamesAndTickers.add({key: value});
        });
      }
      return currencyNamesAndTickers;
    }
    return [];
  }

  @override
  Future<double> getPrice(
      {required String ticker, String vsTicker = 'usd'}) async {
    if (ticker == 'usd') {
      return 1.0;
    }
    return 0.0;
  }

  @override
  Future<double> getMarketCap(
      {required String ticker, String vsTicker = 'usd'}) async {
    return 0.0;
  }
}
