import 'package:flutter/material.dart';
// ignore: unused_import
import 'api_service.dart';

enum AssetType { stock, crypto, cash }

abstract class Asset {
  String? name;
  String? ticker;
  double? quantity;

  double? getPrice();
  double? getValue();
  double? getMarketCap();
  String? getName();
  String? getTicker();
}

class Crypto implements Asset {
  @override
  String? name;

  @override
  String? ticker;

  @override
  double? quantity;

  Crypto(String this.name, double this.quantity) {
    ticker = getTicker();
  }
  Crypto.byWalletAddress(String this.name, String address) {
    ticker = getTicker();
    quantity = getQuantityByAddress(address)!;
  }

  @override
  double? getPrice() {
    return null;

    // return AssetDataAPI(AssetType.crypto).getPrice(ticker!);
  }

  @override
  double getValue() {
    return (getPrice()! * quantity!);
  }

  @override
  String getTicker() {
    return "ETH";
  }

  double? getQuantityByAddress(String address) {
    return 100.0;
  }

  @override
  double? getMarketCap() {
    return 1000000000000;
  }

  @override
  String? getName() {
    return 'Ethereum';
  }
}

/// This is the class that creates the cards that display the information about
/// each user specified asset. vsTicker is passed in because tapping the
/// NetWorthButton toggles
class AssetCard extends StatelessWidget {
  final Asset asset;
  final String vsTicker;

  const AssetCard({
    super.key,
    required this.asset,
    required this.vsTicker,
  });

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
                      asset.getTicker()!.toString(),
                      textScaleFactor: 1.6,
                    ),
                    Text(
                      asset.getName()!,
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
                    Text(asset.quantity!.toString())
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Price ($vsTicker):",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      asset.getPrice().toString(),
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      "Total ($vsTicker): ",
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      asset.getValue()!.toString(),
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
                    "Market Cap: ${asset.getMarketCap()} $vsTicker",
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
}
