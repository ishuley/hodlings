// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'asset.dart';
import 'package:intl/intl.dart';

enum MarketStatus { premarket, afterhours, open, closed }

/// This is the class that creates the cards that display the information about
/// each user specified asset. vsTicker is passed in because tapping the
/// NetWorthButton toggles
class AssetCard extends StatelessWidget {
  final Asset asset;
  final String vsTicker;
  final double price;
  final String marketCapString;
  // final double extendedHoursPrice;
  double get totalValue => price * asset.quantity;

  const AssetCard({
    super.key,
    required this.asset,
    required this.vsTicker,
    required this.price,
    required this.marketCapString,
    // this.extendedHoursPrice = 0,
  });

  // String getExtendedHoursString() {
  //   if (extendedHoursPrice == 0 || asset.assetType != AssetType.stock) {
  //     return '';
  //   }

  //   switch ((asset as Stock).getExtendedHoursStatus()) {
  //     case MarketStatus.afterhours:
  //     case MarketStatus.closed:
  //       return 'After Hours: $extendedHoursPrice';
  //     case MarketStatus.open:
  //       return '';
  //     case MarketStatus.premarket:
  //       return 'Pre-market: $extendedHoursPrice';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).textTheme.labelSmall!.color!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 12.0,
      ),
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
                    asset.name.replaceAll(
                      ' ',
                      '\n',
                    ),
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Qty: ',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    NumberFormat.compact().format(
                      asset.quantity,
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Price \n(${vsTicker.toUpperCase()}):',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    NumberFormat('###,###,###,###,###.00', 'en_US').format(
                      price,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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
                    NumberFormat(
                      '###,###,###,###,###.00',
                      'en_US',
                    ).format(
                      totalValue,
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 7,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  marketCapString,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Text(
                //   getExtendedHoursString(),
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: textColor,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
