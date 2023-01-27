import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodlings/api_service/api_service.dart';
import 'package:hodlings/main_screen/app_bar/sort_by_icon.dart';
import 'package:hodlings/main_screen/asset.dart';
import 'package:hodlings/main_screen/asset_display/asset_card.dart';
import 'package:hodlings/main_screen/net_worth_display/net_worth_notifier.dart';
import 'package:hodlings/main_screen/app_bar/sort_type_notifier.dart';
import 'package:hodlings/persistence/asset_card_list_storage.dart';
import 'package:hodlings/main_screen/vs_ticker_notifier.dart';

final assetCardsListNotifierProvider =
    StateNotifierProvider<AssetCardsListNotifier, List<AssetCard>>(
  (ref) => AssetCardsListNotifier(ref),
);

class AssetCardsListNotifier extends StateNotifier<List<AssetCard>> {
  final Ref ref;
  AssetCardsListNotifier(this.ref) : super([]) {
    ref;
  }

  void readAssetCardList() async {
    state = await AssetCardListStorage().readAssetCardsData();
    ref.read(assetCardsListNotifierProvider.notifier).sortAssetCards();
    ref.read(netWorthNotifierProvider.notifier).updateNetWorth();
  }

  Future<void> saveAssetCardsList() async {
    await AssetCardListStorage().writeAssetCardsData(
      state,
    );
  }

  void deleteAssetCard(int index) async {
    ref
        .read(netWorthNotifierProvider.notifier)
        .decrementNetWorth(state[index].totalValue);
    state.removeAt(index);
    ref.notifyListeners();
    refreshAssetCardsDisplay();
    await saveAssetCardsList();
  }

  void addNewAssetCard(AssetCard newAssetCard) async {
    state.add(newAssetCard);

    ref.read(sortTypeNotifierProvider.notifier).saveSortType();
    ref
        .read(netWorthNotifierProvider.notifier)
        .incrementNetWorth(newAssetCard.totalValue);
    ref.notifyListeners();
    refreshAssetCardsDisplay();
    await saveAssetCardsList();
  }

  void editQuantity(int index, double newQty) async {
    double difference = newQty - state[index].asset.quantity;
    state[index].asset.quantity += difference;
    state[index].asset.dataSourceField = state[index].asset.quantity.toString();
    ref.notifyListeners();
    refreshAssetCardsDisplay();
    await saveAssetCardsList();
  }

  void refreshAssetCardsDisplay() async {
    /// Crypto assets refreshed seperately because CoinGecko lets us save on
    /// API calls by getting all the updated data with one call, whereas the
    /// other APIs do not.
    List<AssetCard> newAssetCardsList = await _getRefreshedCryptoCardList();
    newAssetCardsList.addAll(await _getRefreshedNonCryptoAssetCardList());
    state = newAssetCardsList;
    ref.read(assetCardsListNotifierProvider.notifier).sortAssetCards();
    ref.read(netWorthNotifierProvider.notifier).updateNetWorth();
  }

  void sortAssetCards() async {
    List<AssetCard> sortedList = state.toList();

    switch (ref.read(sortTypeNotifierProvider.notifier).state) {
      case SortType.name:
        ref.read(ascendingProvider.notifier).state
            ? sortedList.sort((b, a) => a.asset.name.compareTo(b.asset.name))
            : sortedList.sort((a, b) => a.asset.name.compareTo(b.asset.name));
        break;
      case SortType.marketCap:
        ref.read(ascendingProvider.notifier).state
            ? sortedList
                .sort((a, b) => a.asset.marketCap.compareTo(b.asset.marketCap))
            : sortedList
                .sort((b, a) => a.asset.marketCap.compareTo(b.asset.marketCap));
        break;
      case SortType.totalValue:
        ref.read(ascendingProvider.notifier).state
            ? sortedList.sort((a, b) => a.totalValue.compareTo(b.totalValue))
            : sortedList.sort((b, a) => a.totalValue.compareTo(b.totalValue));
        break;
      case SortType.price:
        ref.read(ascendingProvider.notifier).state
            ? sortedList.sort((a, b) => a.price.compareTo(b.price))
            : sortedList.sort((b, a) => a.price.compareTo(b.price));
        break;
      case SortType.quantity:
        ref.read(ascendingProvider.notifier).state
            ? sortedList
                .sort((a, b) => a.asset.quantity.compareTo(b.asset.quantity))
            : sortedList
                .sort((b, a) => a.asset.quantity.compareTo(b.asset.quantity));
        break;
    }
    state = sortedList;
    ref.notifyListeners();
  }

  Future<List<AssetCard>> _getRefreshedCryptoCardList() async {
    List<AssetCard> cryptoCards =
        _separateCryptoCardsListFromOldAssetCardList();
    List<String> cryptoIdList = _extractCryptoIdList(cryptoCards);
    Map<String, dynamic> cryptoData = await CryptoAPI().getData(
      ids: cryptoIdList,
      vsTickers: [ref.watch(vsTickerNotifierProvider)],
    );

    List<AssetCard> newAssetCardsList = await _extractNewCryptoCardListFromData(
      cryptoData,
      cryptoIdList,
    );
    return newAssetCardsList;
  }

  List<AssetCard> _separateCryptoCardsListFromOldAssetCardList() {
    List<AssetCard> cryptoCards = [];

    for (AssetCard card in state) {
      if (card.asset.assetType == AssetType.crypto) {
        cryptoCards.add(card);
      }
    }
    return cryptoCards;
  }

  List<String> _extractCryptoIdList(List<AssetCard> cryptoCards) {
    List<String> cryptoIdList = [];
    for (AssetCard cryptoCard in cryptoCards) {
      cryptoIdList.add(
        cryptoCard.asset.assetId,
      );
    }
    return cryptoIdList;
  }

  Future<List<AssetCard>> _extractNewCryptoCardListFromData(
    Map<String, dynamic> cryptoData,
    List<String> cryptoIdList,
  ) async {
    List<AssetCard> newAssetCardsList = [];
    if (cryptoData.isNotEmpty) {
      for (String cryptoId in cryptoIdList) {
        for (AssetCard assetCard in state) {
          if (cryptoId == assetCard.asset.assetId) {
            double newPrice = _extractNewPriceFromCryptoData(
              assetCard,
              cryptoData,
              cryptoId,
            );
            String newMarketCapString = _extractNewMktCapStringFromCryptoData(
              assetCard,
              cryptoData,
              cryptoId,
            );
            newAssetCardsList.add(
              await _refreshAnAssetCard(
                asset: assetCard.asset,
                newPrice: newPrice,
                newMarketCapString: newMarketCapString,
              ),
            );
          }
        }
      }
    }
    return newAssetCardsList;
  }

  double _extractNewPriceFromCryptoData(
    AssetCard assetCard,
    Map<String, dynamic> cryptoData,
    String cryptoId,
  ) {
    String lowerCaseVsTicker =
        ref.watch(vsTickerNotifierProvider).toLowerCase();
    double newPrice = assetCard.price;
    if (cryptoData[cryptoId][lowerCaseVsTicker] != null &&
        cryptoData[cryptoId][lowerCaseVsTicker] != 0) {
      newPrice = cryptoData[cryptoId][lowerCaseVsTicker];
    }
    return newPrice;
  }

  String _extractNewMktCapStringFromCryptoData(
    AssetCard assetCard,
    Map<String, dynamic> cryptoData,
    String cryptoId,
  ) {
    String lowerCaseVsTicker =
        ref.watch(vsTickerNotifierProvider).toLowerCase();
    String newMarketCapString = assetCard.marketCapString;
    if (cryptoData[cryptoId]['${lowerCaseVsTicker}_market_cap'] != null &&
        cryptoData[cryptoId][lowerCaseVsTicker] != 0) {
      double newMarketCap =
          cryptoData[cryptoId]['${lowerCaseVsTicker}_market_cap'];
      newMarketCapString = assetCard.asset.formatMarketCap(newMarketCap);
      newMarketCapString =
          'Market Cap: $newMarketCapString ${lowerCaseVsTicker.toUpperCase()}';
    }
    return newMarketCapString;
  }

  Future<AssetCard> _refreshAnAssetCard({
    required Asset asset,
    required double newPrice,
    required String newMarketCapString,
    // double extendedHoursPrice = 0,
  }) async {
    return AssetCard(
      key: UniqueKey(),
      asset: asset,
      vsTicker: ref.watch(vsTickerNotifierProvider),
      price: newPrice,
      marketCapString: newMarketCapString,
      // extendedHoursPrice: extendedHoursPrice,
    );
  }

  Future<List<AssetCard>> _getRefreshedNonCryptoAssetCardList() async {
    List<AssetCard> newAssetCardsList = [];
    // double extendedHoursPrice = 0;
    for (AssetCard card in state) {
      if (card.asset.assetType != AssetType.crypto) {
        double newPrice = await card.asset.getPrice(
          vsTicker: ref.watch(vsTickerNotifierProvider),
        );
        String newMarketCapString = await card.asset.getMarketCapString(
          vsTicker: ref.watch(vsTickerNotifierProvider),
        );
        // if (card.asset.assetType == AssetType.stock) {
        //   Stock asset = card.asset as Stock;
        //   extendedHoursPrice = await asset.getExtendedHoursPrice();
        // }

        if (newPrice == 0) {
          newPrice = card.price;
        }
        newAssetCardsList.add(
          await _refreshAnAssetCard(
            asset: card.asset,
            newPrice: newPrice,
            newMarketCapString: newMarketCapString,
            // extendedHoursPrice: extendedHoursPrice,
          ),
        );
      }
    }
    return newAssetCardsList;
  }
}
