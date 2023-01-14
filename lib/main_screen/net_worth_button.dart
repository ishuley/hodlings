import 'package:flutter/material.dart';

class NetWorthButton extends StatelessWidget {
  final String netWorth;
  final String vsTicker;
  final VoidCallback onNetWorthClickCallback;
  const NetWorthButton({
    super.key,
    required this.netWorth,
    required this.vsTicker,
    required this.onNetWorthClickCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 75,
            child: TextButton(
              onPressed: onNetWorthClickCallback,
              child: Text(
                '$netWorth $vsTicker',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
