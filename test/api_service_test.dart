import 'package:hodlings/api_service.dart';
import 'package:test/test.dart';

Future<void> main() async {
  test("StockAPI.getPrice()", () async {
    double testPrice =
        await StockAPI().getPrice(ticker: "aapl", vsTicker: "usd");
    expect(testPrice, inInclusiveRange(1, 1000000));
  });
}