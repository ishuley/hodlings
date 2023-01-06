import 'dart:convert';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/coin_short.dart';
import 'package:coingecko_api/data/market.dart';
import 'package:coingecko_api/data/price_info.dart';
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
  Future<List<Map<String, String>>> getAssetData();
  Future<double> getPrice({required String id, String vsTicker});
  Future<double> getMarketCap({required String id, String vsTicker});
}

class CryptoAPI implements AssetAPI {
  final api = CoinGeckoApi();

  @override
  late AssetType assetType;

  @override
  Future<List<Map<String, String>>> getAssetData() async {
    final CoinGeckoResult<List<CoinShort>> result = await api.coins.listCoins();
    List<Map<String, String>> cryptoIDData = [];
    for (CoinShort cryptoDetails in result.data) {
      cryptoIDData.add({
        "id": cryptoDetails.id,
        "name": cryptoDetails.name,
        "ticker": cryptoDetails.symbol
      });
    }
    return cryptoIDData;
  }

  @override
  Future<double> getPrice({required String id, String vsTicker = 'usd'}) async {
    id = id.toLowerCase();
    vsTicker = vsTicker.toLowerCase();
    CoinGeckoResult<List<PriceInfo>> priceData =
        await api.simple.listPrices(ids: [id], vsCurrencies: [vsTicker]);
    for (PriceInfo price in priceData.data) {
      if (price.id == id) {
        return price.getPriceIn('usd')!;
      }
    }
    return 0;
  }

  @override
  Future<double> getMarketCap(
      {required String id, String vsTicker = 'usd'}) async {
    id = id.toLowerCase();
    vsTicker = vsTicker.toLowerCase();
    CoinGeckoResult<List<Market>> marketData =
        await api.coins.listCoinMarkets(coinIds: [id], vsCurrency: vsTicker);
    for (Market market in marketData.data) {
      if (market.id == id || id == "loopring" && market.name == "Loopring") {
        if (market.marketCap != null) {
          return market.marketCap!;
        }
      }
    }
    return 0;
  }
}

class StockAPI implements AssetAPI {
  @override
  late AssetType assetType;

  @override
  Future<List<Map<String, String>>> getAssetData() async {
    Uri url = Uri.http(stockApiUrl, "/api/v3/stock/list",
        {"apikey": stockDataApiKey, "limit": "10000"});

    Response response = await get(url);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
      List<Map<String, String>> stockNamesAndTickers = [];
      for (Map<String, dynamic> stockDataMap in jsonResponse) {
        if (stockDataMap['symbol'] != null && stockDataMap['name'] != null) {
          stockNamesAndTickers.add(
            {
              'id': stockDataMap['symbol'],
              'ticker': stockDataMap['symbol'],
              'name': stockDataMap['name'],
            },
          );
        }
      }
      return stockNamesAndTickers;
    }
    return [];
  }

  @override
  Future<double> getPrice({required String id, String vsTicker = 'USD'}) async {
    id = id.toUpperCase();
    vsTicker = vsTicker.toUpperCase();
    Uri url = Uri.http(stockApiUrl, "/api/v3/quote-short/",
        {"apikey": stockDataApiKey, "symbols": id});
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
      {required String id, String vsTicker = 'USD'}) async {
    id = id.toUpperCase();
    vsTicker = vsTicker.toUpperCase();

    Uri url = Uri.http(stockApiUrl, "/api/v3/market-capitalization/",
        {"apikey": stockDataApiKey, "symbols": id});
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
  Future<List<Map<String, String>>> getAssetData() async {
    Uri url = Uri.https(currencyApiUrl, "/exchangerates_data/symbols",
        {"apikey": currencyExchangeDataApiKey});
    Response response = await get(url);
    if (response.statusCode == 200) {
      List<Map<String, String>> currencyNamesAndTickers = [];

      Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (jsonResponse['success'] == true) {
        Map<String, dynamic> currencyList = jsonResponse['symbols'];
        currencyList.forEach((ticker, name) {
          currencyNamesAndTickers
              .add({'id': ticker, 'ticker': ticker, 'name': name});
        });
      }
      return currencyNamesAndTickers;
    }
    return [];
  }

  @override
  Future<double> getPrice({required String id, String vsTicker = 'usd'}) async {
    if (id == 'usd') {
      return 1.0;
    }
    return 0.0;
  }

  @override
  Future<double> getMarketCap(
      {required String id, String vsTicker = 'usd'}) async {
    return 0.0;
  }
}
