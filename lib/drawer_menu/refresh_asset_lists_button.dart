import 'package:flutter/material.dart';

class RefreshAssetListsButton extends StatefulWidget {
  const RefreshAssetListsButton({super.key});

  @override
  State<RefreshAssetListsButton> createState() =>
      _RefreshAssetListsButtonState();
}

class _RefreshAssetListsButtonState extends State<RefreshAssetListsButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 30,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            'Refresh Asset List (For newly released instruments)',
            style: Theme.of(context).textTheme.labelSmall!,
          ),
        ),
      ),
    );
  }

  void onPressed() {}
}

class RefreshAssetHelpIcon extends StatelessWidget {
  const RefreshAssetHelpIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0, 10, 0),
      child: Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        showDuration: Duration(seconds: 5),
        message:
            'API calls are expensive, so I save the lists of stocks, cryptos, and other instruments to local storage and load them from there. If a new instrument comes into existence (IPO, ICO, carve out, whatever reason), this button will refresh the asset lists to include the new security.',
        child: InkWell(
          child: Icon(
            Icons.question_mark,
          ),
        ),
      ),
    );
  }
}
