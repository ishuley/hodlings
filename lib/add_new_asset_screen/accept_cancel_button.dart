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
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: Theme.of(context)
                          .textButtonTheme
                          .style!
                          .backgroundColor,
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).iconTheme.color!,
                          ),
                        ),
                      ),
                    ),
                    onPressed: acceptPushedCallback,
                    child: Text(
                      'Accept',
                      style:
                          TextStyle(color: Theme.of(context).iconTheme.color),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => {Navigator.pop(context)},
                    style: ButtonStyle(
                      backgroundColor: Theme.of(context)
                          .textButtonTheme
                          .style!
                          .backgroundColor,
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
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
