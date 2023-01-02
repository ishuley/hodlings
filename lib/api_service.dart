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

  Future<List> getAssetNamesAndTickersList() {
    switch (assetType) {
      case AssetType.stock:
        return StockAPI().getAssetNamesAndTickers();
      case AssetType.crypto:
        return CryptoAPI().getAssetNamesAndTickers();
      case AssetType.cash:
        return CashAPI().getAssetNamesAndTickers();
    }
  }

  Future<double> getPrice(String ticker, String vsCurrencySymbol) async {
    switch (assetType) {
      case AssetType.stock:
        return StockAPI().getPrice(ticker, vsCurrencySymbol);
      case AssetType.crypto:
        return await CryptoAPI().getPrice(ticker, vsCurrencySymbol);
      case AssetType.cash:
        return CashAPI().getPrice(ticker, vsCurrencySymbol);
    }
  }

  Future<double> getMarketCap(
      {required String ticker, required String vsTicker}) {
    switch (assetType) {
      case AssetType.stock:
        return StockAPI().getMarketCap(ticker, vsTicker);
      case AssetType.crypto:
        return CryptoAPI().getMarketCap(ticker, vsTicker);
      case AssetType.cash:
        return CashAPI().getMarketCap(ticker, vsTicker);
    }
  }
}

class CryptoAPI {
  final api = CoinGeckoApi();

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

  Future<double> getPrice(String ticker, String vsCurrencySymbol) async {
    CoinGeckoResult<List<Market>> marketData =
        await api.coins.listCoinMarkets(vsCurrency: vsCurrencySymbol);
    for (Market market in marketData.data) {
      if (market.symbol == ticker) {
        return market.currentPrice!;
      }
    }
    return 0;
  }

  Future<double> getMarketCap(String ticker, String vsCurrencySymbol) async {
    CoinGeckoResult<List<Market>> marketData = await api.coins
        .listCoinMarkets(vsCurrency: vsCurrencySymbol.toLowerCase());
    for (Market market in marketData.data) {
      if (market.symbol == ticker.toLowerCase()) {
        return market.marketCap!;
      }
    }
    return 0;
  }
}

class StockAPI {
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

  // TODO: add a function to retrieve multiple prices at once since the API supports bundling calls. This will save on API pings when the user refreshes.

  Future<double> getPrice(String ticker, String vsTicker) async {
    Uri url = Uri.http(stockApiUrl, "/v1/intraday/latest",
        {"access_key": stockDataApiKey, "symbols": ticker});

    double price = 0;
    Response response = await get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      price = jsonResponse['data'][0]['last'];
    }

    return price;
  }

  Future<List<Map<String, double>>> getPrices(
      List<String> tickers, String vsTicker) async {
    Uri url = Uri.http(stockApiUrl, "/v1/intraday/latest",
        {"access_key": stockDataApiKey, "symbols": tickers.join(',')});

    Response response = await get(url);
    List<Map<String, double>> prices = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      var assetDataList = jsonResponse['data'];
      for (Map<String, dynamic> assetData in assetDataList) {
        prices.add({assetData["symbol"]: assetData['last']});
      }
    }
    return prices;
  }

  getMarketCap(String ticker, String vsTicker) {}
}

class CashAPI {
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
