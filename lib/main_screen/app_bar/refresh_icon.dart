import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodlings/main_screen/asset_display/asset_card_list_notifier.dart';

class RefreshAppBarIcon extends ConsumerStatefulWidget {
  const RefreshAppBarIcon({
    super.key,
  });

  @override
  ConsumerState<RefreshAppBarIcon> createState() => _RefreshAppBarIconState();
}

class _RefreshAppBarIconState extends ConsumerState<RefreshAppBarIcon> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        12,
      ),
      child: InkWell(
        onTap: onRefresh,
        splashColor: Colors.purple,
        child: const Icon(
          Icons.refresh_outlined,
        ),
      ),
    );
  }

  void onRefresh() async {
    ref
        .read(assetCardsListNotifierProvider.notifier)
        .refreshAssetCardsDisplay();
  }
}
