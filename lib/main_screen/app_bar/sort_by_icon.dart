import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodlings/main_screen/app_bar/sort_type_notifier.dart';
import 'package:hodlings/main_screen/asset_display/asset_card_list_notifier.dart';
import 'package:hodlings/main_screen/net_worth_display/net_worth_notifier.dart';

enum SortType { totalValue, marketCap, price, quantity, name }

class SortAppBarIcon extends ConsumerStatefulWidget {
  const SortAppBarIcon({
    super.key,
  });

  @override
  ConsumerState<SortAppBarIcon> createState() => _SortAppBarIconState();
}

class _SortAppBarIconState extends ConsumerState<SortAppBarIcon> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (SortType selectedSortType) {
        ref
            .read(sortTypeNotifierProvider.notifier)
            .setSortType(selectedSortType);

        ref.read(assetCardsListNotifierProvider.notifier).sortAssetCards();
        ref.read(netWorthNotifierProvider.notifier).updateNetWorth();
      },
      splashRadius: 22,
      position: PopupMenuPosition.under,
      initialValue: ref.watch(sortTypeNotifierProvider),
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
