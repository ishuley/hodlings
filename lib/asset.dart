import 'package:flutter/material.dart';
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

  Future<double> getPrice({String vsTicker = 'usd'}) {
    throw UnimplementedError(
        "This should never get called because Asset is an abstract class. Initialize the object as one of it's subclasses, Stock, Crypto, Cash, NFT, etc.");
  }

  Future<double> getMarketCap({String vsTicker = 'usd'}) {
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
  Future<double> getPrice({String vsTicker = 'usd'}) async {
    return await AssetAPI(AssetType.crypto)
        .getPrice(ticker: ticker, vsTicker: vsTicker);
  }

  @override
  Future<double> getMarketCap({String vsTicker = 'usd'}) async {
    return await AssetAPI(AssetType.crypto)
        .getMarketCap(ticker: ticker, vsTicker: vsTicker);
  }

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
  final String marketCapString;

  const AssetCard({
    super.key,
    required this.asset,
    required this.vsTicker,
    required this.price,
    required this.marketCapString,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
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
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Text(
                    asset.name,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Qty: ",
                  ),
                  Text(asset.quantity.toStringAsFixed(2))
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Price (${vsTicker.toUpperCase()}):",
                  ),
                  Text(price.toStringAsFixed(2)),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    "Total (${vsTicker.toUpperCase()}): ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    totalValue.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                  marketCapString,
                  style: const TextStyle(fontSize: 12),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
