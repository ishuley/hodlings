import 'package:flutter_riverpod/flutter_riverpod.dart';

/// This is a notifier to accomodate plans to add functionality later.

final vsTickerNotifierProvider =
    StateNotifierProvider<VsTickerNotifier, String>(
  (ref) => VsTickerNotifier(ref),
);

class VsTickerNotifier extends StateNotifier<String> {
  final Ref ref;
  VsTickerNotifier(this.ref) : super('USD') {
    ref;
  }
}
