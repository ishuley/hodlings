abstract class Asset {
  String symbol;
  double value = 0;
  double price = 0;
  double quantity = 0;

  Asset(this.symbol) {
    price = getPrice();
  }
  void refreshData() {
    price = getPrice();
    quantity = getQuantity();
    value = getValue();
  }

  double getPrice();
  double getQuantity();
  double getValue() {
    return price * quantity;
  }
}

abstract class Crypto extends Asset {
  Crypto(super.symbol);

  @override
  double getPrice() {
    return 2.0;
  }
}

class CryptoByAddress extends Crypto {
  String address;

  CryptoByAddress(this.address, super.symbol) {
    quantity = getQuantity();
  }

  @override
  double getQuantity() {
    return 2.0;
  }
}

class CryptoByQTY extends Crypto {
  double qty;
  CryptoByQTY(super.symbol, this.qty) {
    quantity = qty;
  }

  setQuantity(double qty) {
    quantity = qty;
  }

  @override
  double getQuantity() {
    return quantity;
  }
}

abstract class Stock extends Asset {
  Stock(super.symbol);

  @override
  double getPrice() {
    return 2.0;
  }
}

class StockByQTY extends Stock {
  double qty;
  StockByQTY(super.symbol, this.qty) {
    quantity = qty;
  }

  setQuantity(double qty) {
    quantity = qty;
  }

  @override
  double getQuantity() {
    return quantity;
  }
}
