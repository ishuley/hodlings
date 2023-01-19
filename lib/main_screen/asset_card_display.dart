import 'package:flutter/material.dart';
import 'package:hodlings/main_screen/asset_card.dart';

class AssetCardDisplay extends StatefulWidget {
  final List<AssetCard> assetList;
  final Function(int) deleteAssetCardCallback;
  final Function(int, double) editAssetCardQuantityCallback;
  final Future<void> Function() onRefreshedCallback;

  const AssetCardDisplay({
    super.key,
    required this.assetList,
    required this.deleteAssetCardCallback,
    required this.editAssetCardQuantityCallback,
    required this.onRefreshedCallback,
  });

  @override
  State<AssetCardDisplay> createState() => _AssetCardDisplayState();
}

class _AssetCardDisplayState extends State<AssetCardDisplay> {
  Offset _tapPosition = Offset.zero;
  int _tappedCardIndex = 0;
  late ContextMenuSelection _contextChoice;
  late TextEditingController _editQtyController;
  double? _newQty;

  @override
  void initState() {
    super.initState();
    _editQtyController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assetList.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefreshedCallback,
        child: ListView.builder(
          itemCount: widget.assetList.length,
          itemBuilder: (BuildContext newContext, int index) {
            return GestureDetector(
              onTapDown: (details) {
                _getTapPosition(details, context);
                _storeIndex(index);
              },
              onLongPress: () {
                _showContextMenu(context);
              },
              child: Card(
                child: widget.assetList[index],
              ),
            );
          },
        ),
      );
    }
    return const Align(
      alignment: Alignment.center,
      child: Text(
        'No assets entered yet',
        textAlign: TextAlign.center,
      ),
    );
  }

  void _getTapPosition(TapDownDetails details, BuildContext context) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    _tapPosition = referenceBox.globalToLocal(details.globalPosition);
  }

  void _storeIndex(int index) {
    _tappedCardIndex = index;
  }

  void _showContextMenu(BuildContext context) async {
    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();

    ContextMenuSelection? userChoice =
        await _showLongpressMenu(context, overlay);
    if (userChoice != null) {
      _contextChoice = userChoice;
    }
    if (userChoice == ContextMenuSelection.edit) {
      await getNewQuantityFromUser();
    }
    _executeChosenAction();
  }

  Future<void> getNewQuantityFromUser() async {
    String inputQty;
    inputQty = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit quantity',
          ),
          content: TextField(
            onEditingComplete: (() =>
                Navigator.of(context).pop(_editQtyController.text)),
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'New quantity',
            ),
            controller: _editQtyController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_editQtyController.text);
              },
              child: const Text(
                'Accept',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
              ),
            ),
          ],
        );
      },
    );
    if (inputQty.isNotEmpty) {
      _newQty = double.parse(inputQty);
    }
  }

  Future<ContextMenuSelection?> _showLongpressMenu(
    BuildContext context,
    RenderObject? overlay,
  ) async {
    ContextMenuSelection? userChoice = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(_tapPosition.dx + 140, _tapPosition.dy + 85, 30, 30),
        Rect.fromLTWH(
          0,
          0,
          overlay!.paintBounds.size.width,
          overlay.paintBounds.size.height,
        ),
      ),
      items: [
        const PopupMenuItem(
          value: ContextMenuSelection.edit,
          child: Text('Edit quantity'),
        ),
        const PopupMenuItem(
          value: ContextMenuSelection.delete,
          child: Text('Delete asset'),
        ),
      ],
    );
    return userChoice;
  }

  void _executeChosenAction() {
    if (_contextChoice == ContextMenuSelection.delete) {
      widget.deleteAssetCardCallback(_tappedCardIndex);
    }
    if (_newQty != null) {
      widget.editAssetCardQuantityCallback(_tappedCardIndex, _newQty!);
    }
  }
}

enum ContextMenuSelection { delete, edit }
