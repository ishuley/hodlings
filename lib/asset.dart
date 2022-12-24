import 'package:flutter/material.dart';
import 'api_service.dart';

enum AssetType { stock, crypto, nft, cash }

abstract class Asset {
  String? name;
  String? ticker;
  double? quantity;

  double? getPrice();
  double? getValue();
  double? getMarketCap();
  String? getNameFromTicker();
}

class Crypto implements Asset {
  @override
  String? name;

  @override
  String? ticker;

  @override
  double? quantity;

  Crypto(String this.ticker, double this.quantity) {
    name = getNameFromTicker();
  }
  Crypto.byWalletAddress(String this.ticker, String address) {
    name = getNameFromTicker();
    quantity = getQuantityByAddress(address)!;
  }

  @override
  double? getPrice() {
    return AssetDataAPI(AssetType.crypto).getPrice(ticker!);
  }

  @override
  double getValue() {
    return (getPrice()! * quantity!);
  }

  @override
  String getNameFromTicker() {
    throw UnimplementedError();
  }

  double? getQuantityByAddress(String address) {
    return 100.0;
  }

  @override
  double? getMarketCap() {
    return 1000000000000;
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
      padding: const EdgeInsets.all(6.0),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: OutlinedButton(
          onPressed: () => {},
          style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.black54),
              foregroundColor: MaterialStatePropertyAll<Color>(Colors.white)),
          onLongPress: () => {},
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Text(
                        asset.ticker!,
                        textScaleFactor: 1.6,
                      ),
                      Text(
                        asset.getNameFromTicker()!,
                        textScaleFactor: 0.75,
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
                      Text("Price $vsTicker:"),
                      Text(
                        asset.getPrice().toString(),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        textAlign: TextAlign.center,
                        "Total: ",
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
                      asset.getMarketCap().toString() + vsTicker,
                      textScaleFactor: 0.75,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
