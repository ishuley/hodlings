import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodlings/main_screen/asset_display/asset_card.dart';
import 'package:hodlings/main_screen/asset_display/asset_card_list_notifier.dart';

final netWorthNotifierProvider =
    StateNotifierProvider<NetWorthNotifier, double>(
  (ref) => NetWorthNotifier(ref),
);

class NetWorthNotifier extends StateNotifier<double> {
  final Ref ref;
  NetWorthNotifier(this.ref) : super(0) {
    ref;
  }

  void updateNetWorth() {
    state = 0;
    for (AssetCard assetCard in ref.watch(assetCardsListNotifierProvider)) {
      incrementNetWorth(
        assetCard.totalValue,
      );
    }
  }

  void incrementNetWorth(double incrementAmount) {
    state = state + incrementAmount;
  }

  void decrementNetWorth(double decrementAmount) {
    state = state - decrementAmount;
  }

  void onNetWorthButtonPressed() {
    // TODO Make this listener update the vsTicker appropriately to the next available vsCurrency when pressed.
    throw UnimplementedError(
      'Soon the plan to is to make this button cycle through a user selected list of vs tickers (the ones that the asset valuations are expressed in, default USD)',
    );
  }
}
