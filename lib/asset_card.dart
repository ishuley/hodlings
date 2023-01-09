import 'package:flutter/material.dart';

import 'asset.dart';

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
    final Color textColor = Theme.of(context).textTheme.labelSmall!.color!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.ticker,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: textColor),
                  ),
                  Text(
                    asset.name,
                    style: TextStyle(fontSize: 10, color: textColor),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Qty: ",
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    asset.quantity.toStringAsFixed(2),
                    style: TextStyle(color: textColor),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Price (${vsTicker.toUpperCase()}):",
                    style: TextStyle(color: textColor),
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: textColor),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    totalValue.toStringAsFixed(2),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: textColor),
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
                  style: TextStyle(fontSize: 12, color: textColor),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
