import 'package:flutter/material.dart';

enum SortType { totalValue, marketCap, price, quantity, name }

class SortAppBarIcon extends StatefulWidget {
  final void Function() sortCallback;
  final void Function(SortType) setSortTypeCallback;
  final SortType currentSortType;

  const SortAppBarIcon({
    super.key,
    required this.sortCallback,
    required this.setSortTypeCallback,
    required this.currentSortType,
  });

  @override
  State<SortAppBarIcon> createState() => _SortAppBarIconState();
}

class _SortAppBarIconState extends State<SortAppBarIcon> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      color: Theme.of(context).selectedRowColor,
      onSelected: (SortType newSelection) {
        setState(
          () {
            widget.setSortTypeCallback(newSelection);
            widget.sortCallback();
          },
        );
      },
      splashRadius: 22,
      position: PopupMenuPosition.under,
      initialValue: widget.currentSortType,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
        const PopupMenuItem<SortType>(
          value: SortType.totalValue,
          child: Text(
            'Total Value',
          ),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.marketCap,
          child: Text(
            'Market Cap',
          ),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.price,
          child: Text(
            'Price',
          ),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.quantity,
          child: Text(
            'Quantity',
          ),
        ),
        const PopupMenuItem<SortType>(
          value: SortType.name,
          child: Text(
            'Name',
          ),
        ),
      ],
      icon: const Icon(
        Icons.sort,
      ),
    );
  }
}
