import 'dart:convert';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/coin_short.dart';
import 'package:coingecko_api/data/market.dart';
import 'asset.dart';
import 'package:coingecko_api/coingecko_api.dart';
import 'package:http/http.dart';
import 'api_keys.dart';

class AssetAPI {
  AssetType assetType;
  AssetAPI(this.assetType);

  Future<List?> getAssetNamesAndTickersList() {
    switch (assetType) {
      case AssetType.crypto:
        return CryptoAPI().getAssetNamesAndTickers();
      case AssetType.cash:
        return CashAPI().getAssetNamesAndTickers();
      default:
        return StockAPI().getAssetNamesAndTickers();
    }
  }

  Future<double?> getPrice(String symbol, String vsCurrencySymbol) async {
    switch (assetType) {
      case AssetType.crypto:
        return await CryptoAPI().getPrice(symbol, vsCurrencySymbol);
      case AssetType.cash:
        return CashAPI().getPrice(symbol, vsCurrencySymbol);
      default:
        return StockAPI().getPrice(symbol, vsCurrencySymbol);
    }
  }

  Future<double?> getMarketCap(
      {required String ticker, required String vsTicker}) {
    switch (assetType) {
      case AssetType.crypto:
        return CryptoAPI().getMarketCap(ticker, vsTicker);
      case AssetType.cash:
        return CashAPI().getMarketCap(ticker, vsTicker);
      default:
        return StockAPI().getMarketCap(ticker, vsTicker);
    }
  }
}

class CryptoAPI {
  final api = CoinGeckoApi();

  Future<List<Map<String, String>>?> getAssetNamesAndTickers() async {
    final CoinGeckoResult<List<CoinShort>> result =
        await api.coins.listCoins(includePlatforms: true);
    if (!result.isError) {
      List<Map<String, String>> cryptoNameAndTickerList = [];
      for (CoinShort cryptoDetails in result.data) {
        cryptoNameAndTickerList.add({cryptoDetails.symbol: cryptoDetails.name});
      }
      return cryptoNameAndTickerList;
    }
    return null;
  }

  Future<double?> getPrice(String symbol, String vsCurrencySymbol) async {
    CoinGeckoResult<List<Market>> marketData =
        await api.coins.listCoinMarkets(vsCurrency: vsCurrencySymbol);
    for (Market market in marketData.data) {
      if (market.symbol == symbol) {
        return market.currentPrice;
      }
    }
    return null;
  }

  Future<double?> getMarketCap(String symbol, String vsCurrencySymbol) async {
    CoinGeckoResult<List<Market>> marketData =
        await api.coins.listCoinMarkets(vsCurrency: vsCurrencySymbol);
    for (Market market in marketData.data) {
      if (market.symbol == symbol) {
        return market.marketCap;
      }
    }
    return null;
  }
}

class StockAPI {
  final stockApiUrl = "api.marketstack.com";

  Future<List<Map<String, String>>> getAssetNamesAndTickers() async {
    Uri url = Uri.http(stockApiUrl, "/v1/tickers",
        {"access_key": stockDataApiKey, "limit": "10000"});

    Response response = await get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
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
    }
    return [];
  }

  double getPrice(String ticker, String vsTicker) {
    return 2.0;
  }

  getMarketCap(String ticker, String vsTicker) {}
}

class CashAPI {
  final currencyApiUrl = "api.apilayer.com";

  Future<List> getAssetNamesAndTickers() async {
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

  double getPrice(String ticker, String vsTicker) {
    return 1.0;
  }

  getMarketCap(String ticker, String vsTicker) {}
}
