import 'package:flutter/material.dart';
import 'add_new_asset_screen.dart';

/// A set of buttons at the bottom of [AddNewAssetScreen].
///
/// "Accept" indicates that the user would like to add the selected asset and
/// quantity to their portfolio, and calls the appropriate callback,
/// [onAcceptButtonPressed]. Cancel backs out by popping the context
/// through the Navigator.
class AcceptCancelButton extends StatelessWidget {
  final VoidCallback acceptPushedCallback;
  const AcceptCancelButton({super.key, required this.acceptPushedCallback});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: acceptPushedCallback,
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.black87),
                      foregroundColor:
                          MaterialStatePropertyAll<Color>(Colors.white70),
                    ),
                    child: const Text(
                      "Accept",
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => {Navigator.pop(context)},
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.black38),
                      foregroundColor:
                          MaterialStatePropertyAll<Color>(Colors.white70),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
