import 'package:flutter/material.dart';
// ignore: unused_import
import 'api_service.dart';

enum AssetType { stock, crypto, cash }

abstract class Asset {
  final String assetFieldData;
  late String name;
  late String ticker;

  Asset(this.assetFieldData) {
    List splitAssetFieldData = assetFieldData.split(" - ");
    ticker = splitAssetFieldData.elementAt(0);
    name = splitAssetFieldData.elementAt(1);
  }

  double quantity = 0;

  Future<double?> getPrice({required String vsTicker}) {
    throw UnimplementedError(
        "This should never get called because Asset is an abstract class. Initialize the object as one of it's subclasses, Stock, Crypto, Cash, NFT, etc.");
  }

  Future<double?> getMarketCap({required String vsTicker}) {
    throw UnimplementedError(
        "This should never get called because Asset is an abstract class. Initialize the object as one of it's subclasses, Stock, Crypto, Cash, NFT, etc.");
  }
}

class Crypto extends Asset {
  late double qty;

  @override
  Crypto(super.assetFieldData, {required double qty}) {
    quantity = qty;
  }
  Crypto.byAddress(super.assetFieldData, {required String address}) {
    quantity = getQuantityFromBlockchainAddress(address);
  }

  @override
  Future<double> getPrice({required String vsTicker}) async {
    return await AssetAPI(AssetType.crypto).getPrice(ticker, vsTicker);
  }

  @override
  Future<double?> getMarketCap({required String vsTicker}) async =>
      await AssetAPI(AssetType.crypto)
          .getMarketCap(ticker: ticker, vsTicker: vsTicker);

  double getQuantityFromBlockchainAddress(String address) {
    return 2.0;
  }
}

class Stock extends Asset {
  Stock(super.assetFieldData);
}

class Cash extends Asset {
  Cash(super.assetFieldData);
}

/// This is the class that creates the cards that display the information about
/// each user specified asset. vsTicker is passed in because tapping the
/// NetWorthButton toggles
class AssetCard extends StatelessWidget {
  final Asset asset;
  final String vsTicker;

  final double price;

  double get totalValue => price * asset.quantity;

  const AssetCard(
      {super.key,
      required this.asset,
      required this.vsTicker,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Text(
                      asset.ticker,
                      textScaleFactor: 1.6,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      asset.name,
                      textScaleFactor: 0.8,
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Qty: ",
                    ),
                    Text(asset.quantity.toString())
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Price ($vsTicker):",
                    ),
                    Text(price.toString()),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      "Total ($vsTicker): ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      totalValue.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    retrieveMarketCapStringForAssetCard(),
                    textScaleFactor: 0.9,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String retrieveMarketCapStringForAssetCard() {
    double? marketCap = asset.getMarketCap(vsTicker: vsTicker) as double?;
    String marketCapAsString = marketCap.toString();
    return "Market Cap: $marketCapAsString  $vsTicker";
  }

  String retrievePrice() {
    double? price = asset.getPrice(vsTicker: vsTicker) as double?;
    return price.toString();
  }
}
