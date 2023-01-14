import 'package:flutter/material.dart';

class AddNewAssetButton extends StatefulWidget {
  final VoidCallback addNewAssetCallback;

  const AddNewAssetButton({super.key, required this.addNewAssetCallback});

  @override
  State<AddNewAssetButton> createState() => _AddNewAssetButtonState();
}

class _AddNewAssetButtonState extends State<AddNewAssetButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 75,
              child: TextButton(
                onPressed: widget.addNewAssetCallback,
                child: Icon(
                  Icons.add,
                  size: Theme.of(context).iconTheme.size,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
