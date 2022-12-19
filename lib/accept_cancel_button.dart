import 'package:flutter/material.dart';

class AcceptCancelButton extends StatefulWidget {
  const AcceptCancelButton({super.key});

  @override
  State<AcceptCancelButton> createState() => _AcceptCancelButtonState();
}

class _AcceptCancelButtonState extends State<AcceptCancelButton> {
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
                    onPressed: onAccept,
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
                    onPressed: onCancel,
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

  void onAccept() {}

  void onCancel() {
    Navigator.pop(context);
  }
}
