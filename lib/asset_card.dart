// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'asset.dart';
import 'package:intl/intl.dart';

/// This is the class that creates the cards that display the information about
/// each user specified asset. vsTicker is passed in because tapping the
/// NetWorthButton toggles
class AssetCard extends StatelessWidget {
  final Asset asset;
  final String vsTicker;
  final double price;
  final String marketCapString;
  double get totalValue => price * asset.quantity;

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
                      color: textColor,
                    ),
                  ),
                  Text(
                    asset.name.replaceAll(' ', '\n'),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Qty: ',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    NumberFormat.compact().format(asset.quantity),
                    style: TextStyle(color: textColor),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Price \n(${vsTicker.toUpperCase()}):',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    NumberFormat('###,###,###,###,###.00', 'en_US')
                        .format(price),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    'Total (${vsTicker.toUpperCase()}): ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    NumberFormat('###,###,###,###,###.00', 'en_US')
                        .format(totalValue),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
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
