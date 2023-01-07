class AssetDataItem {
  final String id;
  final String name;
  final String ticker;

  AssetDataItem(this.id, this.name, this.ticker);

  factory AssetDataItem.fromJson(Map<String, dynamic> jsonDecodedAsset) {
    return AssetDataItem(
      jsonDecodedAsset['id']!,
      jsonDecodedAsset['name']!,
      jsonDecodedAsset['ticker']!,
    );
  }

  Map<String, String> toJson() {
    return {'id': id, 'name': name, 'ticker': ticker};
  }
}
