import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodlings/main_screen/net_worth_display/net_worth_notifier.dart';
import 'package:hodlings/main_screen/vs_ticker_notifier.dart';
import 'package:intl/intl.dart';

class NetWorthButton extends ConsumerWidget {
  const NetWorthButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String netWorthString = NumberFormat(
      '###,###,###,###,###,###',
      'en_US',
    ).format(
      ref.watch(netWorthNotifierProvider),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 75,
              child: TextButton(
                onPressed: ref
                    .read(netWorthNotifierProvider.notifier)
                    .onNetWorthButtonPressed,
                child: Text(
                  '$netWorthString ${ref.watch(vsTickerNotifierProvider)}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
