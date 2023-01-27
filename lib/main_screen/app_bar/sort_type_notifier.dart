import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodlings/main_screen/app_bar/sort_by_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sortTypeNotifierProvider =
    StateNotifierProvider<SortTypeNotifier, SortType>(
  (ref) => SortTypeNotifier(ref),
);

final ascendingProvider = StateProvider<bool>((ref) {
  return false;
});

class SortTypeNotifier extends StateNotifier<SortType> {
  final Ref ref;
  SortTypeNotifier(this.ref) : super(SortType.totalValue) {
    ref;
  }

  Future<void> initSortTypeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sortTypeString = prefs.getString(
      'lastSortType',
    );
    final bool? isAscending = prefs.getBool(
      'isAscending',
    );
    if (sortTypeString != null) {
      state = _getSortTypeFromString(sortTypeString);
    }
    if (isAscending != null) {
      ref.read(ascendingProvider.notifier).state = isAscending;
    }
  }

  void setSortType(SortType newSortType) {
    state = newSortType;
    saveSortType();
  }

  void toggleSortDirectionAscending() {
    bool currentState = ref.read(ascendingProvider.notifier).state;
    ref.read(ascendingProvider.notifier).state = !currentState;
  }

  void saveSortType() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'lastSortType',
      _getSortTypeStringFromEnum(),
    );
    await prefs.setBool(
      'isAscending',
      ref.read(ascendingProvider.notifier).state,
    );
  }

  String _getSortTypeStringFromEnum() {
    switch (state) {
      case SortType.quantity:
        return 'quantity';
      case SortType.price:
        return 'price';
      case SortType.name:
        return 'name';
      case SortType.marketCap:
        return 'marketCap';
      default:
        return 'totalValue';
    }
  }

  SortType _getSortTypeFromString(
    String sortTypeString,
  ) {
    switch (sortTypeString) {
      case 'totalValue':
        return SortType.totalValue;
      case 'marketCap':
        return SortType.marketCap;
      case 'price':
        return SortType.price;
      case 'quantity':
        return SortType.quantity;
      case 'name':
        return SortType.name;
    }
    throw ArgumentError(
      'invalid sort type read from prefs somehow, should not be happening',
    );
  }
}
