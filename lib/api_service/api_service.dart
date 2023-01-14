import 'dart:convert';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/coin_short.dart';
import 'package:coingecko_api/data/market.dart';
import 'package:coingecko_api/data/price_info.dart';
import 'package:hodlings/main_screen/asset.dart';
import 'package:hodlings/persistence/asset_data_item.dart';
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
  Future<List<AssetDataItem>> getListOfAssets();
  Future<double> getPrice({required String id, String vsTicker});
  Future<double> getMarketCap({required String id, String vsTicker});
}

class CryptoAPI implements AssetAPI {
  final api = CoinGeckoApi();

  @override
  late AssetType assetType;

  @override
  Future<List<AssetDataItem>> getListOfAssets() async {
    final CoinGeckoResult<List<CoinShort>> result = await api.coins.listCoins();
    List<AssetDataItem> cryptoData = [];
    for (CoinShort cryptoDetails in result.data) {
      cryptoData.add(
        AssetDataItem(
          cryptoDetails.id,
          cryptoDetails.name,
          cryptoDetails.symbol,
        ),
      );
    }
    return cryptoData;
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
  Future<double> getMarketCap({
    required String id,
    String vsTicker = 'usd',
  }) async {
    id = id.toLowerCase();
    vsTicker = vsTicker.toLowerCase();
    CoinGeckoResult<List<Market>> marketData =
        await api.coins.listCoinMarkets(coinIds: [id], vsCurrency: vsTicker);
    for (Market market in marketData.data) {
      if (market.id == id || id == 'loopring' && market.name == 'Loopring') {
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
  Future<List<AssetDataItem>> getListOfAssets() async {
    Uri url = Uri.https(
      iexApiUrl,
      '/stable/ref-data/symbols',
      {'token': iexApiKey},
    );

    Response response = await get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body) as List<dynamic>;
      List<AssetDataItem> stockNamesAndTickers = [];
      for (Map<String, dynamic> stockDataMap in jsonResponse) {
        stockNamesAndTickers.add(
          AssetDataItem(
            stockDataMap['symbol'],
            stockDataMap['name'],
            stockDataMap['symbol'],
          ),
        );
      }
      return stockNamesAndTickers;
    }
    return [];
  }

  @override
  Future<double> getPrice({required String id, String vsTicker = 'USD'}) async {
    id = id.toLowerCase();
    vsTicker = vsTicker.toLowerCase();
    Uri url = Uri.https(
      iexApiUrl,
      '/stable/stock/$id/quote/latestPrice',
      {'token': iexApiKey},
    );

    Response response = await get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body).toDouble();
    }
    return 0.0;
  }

  @override
  Future<double> getMarketCap({
    required String id,
    String vsTicker = 'usd',
  }) async {
    id = id.toLowerCase();
    vsTicker = vsTicker.toLowerCase();
    Uri url = Uri.https(
      iexApiUrl,
      '/stable/stock/$id/quote/marketCap',
      {'token': iexApiKey},
    );
    Response response = await get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body).toDouble();
    }
    return 0;
  }
}

class CashAPI implements AssetAPI {
  @override
  late AssetType assetType;

  @override
  Future<List<AssetDataItem>> getListOfAssets() async {
    Uri url = Uri.https(
      currencyApiUrl,
      '/exchangerates_data/symbols',
      {'apikey': currencyExchangeDataApiKey},
    );

    Response response = await get(url);
    List<AssetDataItem> currencyData = [];
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (jsonResponse['success'] == true) {
        Map<String, dynamic> currencyList = jsonResponse['symbols'];

        for (MapEntry<String, dynamic> currency in currencyList.entries) {
          currencyData.add(
            AssetDataItem(
              currency.key.toUpperCase(),
              currency.value,
              currency.key.toUpperCase(),
            ),
          );
        }
      }
      return currencyData;
    }
    return [];
  }

  @override
  Future<double> getPrice({required String id, String vsTicker = 'usd'}) async {
    if (id.toLowerCase() == vsTicker.toLowerCase()) {
      return 1.0;
    }
    Uri url = Uri.https(currencyApiUrl, '/exchangerates_data/convert', {
      'apikey': currencyExchangeDataApiKey,
      'amount': '1',
      'from': id,
      'to': vsTicker
    });
    Response response = await get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse['result'];
    }

    return 0;
  }

  @override
  Future<double> getMarketCap({
    required String id,
    String vsTicker = 'usd',
  }) async {
    return 0.0;
  }
}
