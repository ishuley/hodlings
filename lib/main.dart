import 'package:flutter/material.dart';
import 'add_new_asset_screen.dart';

void main() => runApp(
      MaterialApp(
        routes: {
          '/': (context) => const MainScreen(),
          '/addNewAsset': (context) => const AddNewAssetScreen(),
        },
      ),
    );

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String netWorth = "0";
  String symbol = "USD";

  void onNetWorthButtonPressed() {
    setState(() {
      // TODO rip out this placeholder code and make this screen update appropriately
      if (netWorth == "1,000,000") {
        netWorth = "1,000";
        symbol = "ETH";
      } else {
        netWorth = "1,000,000";
        symbol = "USD";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("HODLings"),
          foregroundColor: Colors.white70,
          centerTitle: true,
          backgroundColor: Colors.grey[900],
        ),
        drawer: const DrawerMenu(),
        body: Container(
          color: Colors.grey[850],
          child: Center(
            child: Column(
              children: [
                NetWorthButton(
                  netWorth: netWorth,
                  symbol: symbol,
                  onNetWorthClickCallback: onNetWorthButtonPressed,
                ),
                // ExampleAssetCard(),
                const AddNewAssetButton(),
              ],
            ),
          ),
        ));
  }
}

class NetWorthButton extends StatefulWidget {
  final String netWorth;
  final String symbol;
  final VoidCallback onNetWorthClickCallback;

  const NetWorthButton(
      {super.key,
      required this.netWorth,
      required this.symbol,
      required this.onNetWorthClickCallback});

  @override
  State<NetWorthButton> createState() => _NetWorthButtonState();
}

class _NetWorthButtonState extends State<NetWorthButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 75,
            child: TextButton(
                onPressed: widget.onNetWorthClickCallback,
                style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.black),
                  foregroundColor:
                      MaterialStatePropertyAll<Color>(Colors.white70),
                ),
                child: Text(
                  "${widget.netWorth} ${widget.symbol}",
                  textScaleFactor: 1.8,
                )),
          ),
        ),
      ],
    );
  }
}

class AddNewAssetButton extends StatefulWidget {
  const AddNewAssetButton({super.key});

  @override
  State<AddNewAssetButton> createState() => _AddNewAssetButtonState();
}

class _AddNewAssetButtonState extends State<AddNewAssetButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: 75,
            child: TextButton(
              onPressed: onPressed,
              style: const ButtonStyle(
                backgroundColor:
                    MaterialStatePropertyAll<Color>(Colors.black26),
                foregroundColor:
                    MaterialStatePropertyAll<Color>(Colors.white54),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        )
      ]),
    );
  }

  void onPressed() {
    Navigator.pushNamed(context, '/addNewAsset');
  }
}

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Colors.grey[850],
        child: ListView(
          children: const [],
        ));
  }
}
