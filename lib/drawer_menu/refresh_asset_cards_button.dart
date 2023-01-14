import 'package:flutter/material.dart';

class RefreshAssetCardsButton extends StatefulWidget {
  final VoidCallback onRefreshAssetCardsCallback;
  const RefreshAssetCardsButton({
    super.key,
    required this.onRefreshAssetCardsCallback,
  });

  @override
  State<RefreshAssetCardsButton> createState() =>
      _RefreshAssetCardsButtonState();
}

class _RefreshAssetCardsButtonState extends State<RefreshAssetCardsButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 30,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
        child: TextButton(
          onPressed: widget.onRefreshAssetCardsCallback,
          child: Text(
            'Refresh Assets (For MacOS users who can\'t pull the list down to refresh)',
            style: Theme.of(context).textTheme.labelSmall!,
          ),
        ),
      ),
    );
  }
}
