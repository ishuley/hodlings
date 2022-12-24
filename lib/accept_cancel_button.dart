import 'package:flutter/material.dart';

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
