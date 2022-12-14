class APIService {
  String assetType;
  APIService(this.assetType);

  List<String> getAssetList() {
    if (assetType == "crypto") {
      return CryptoAPI().getAssetList();
    }
    if (assetType == "nft") {
      return NftAPI().getAssetList();
    }
    if (assetType == "cash") {
      return CashAPI().getAssetList();
    }
    return StockAPI().getAssetList();
  }
}

class CashAPI {
  List<String> getAssetList() {
    return <String>[
      "US Dollar",
      "Euro",
      "Georgian Lari",
    ];
  }
}

class StockAPI {
  List<String> getAssetList() {
    return <String>[
      "GameStop",
      "Other Stock",
    ];
  }
}

class CryptoAPI {
  List<String> getAssetList() {
    return <String>[
      "Ethereum",
      "Monero",
      "Bitcoin Cash",
    ];
  }
}

class NftAPI {
  List<String> getAssetList() {
    return <String>[
      "Cyber Crew Card",
      "A strapped banana brain ape",
      "A Kira",
    ];
  }
}
