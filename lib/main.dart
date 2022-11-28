import 'package:flutter/material.dart';

void main() => runApp(
      const MaterialApp(
        home: MainScreen(),
      ),
    );

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
              children: const [
                NetWorthButton(),
                AssetList(),
                AddNewAssetButton(),
              ],
            ),
          ),
        ));
  }
}

class AddNewAssetButton extends StatelessWidget {
  const AddNewAssetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.bottomCenter,
        child: Row(
          children: [
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
                    child: const Text(
                      "+",
                      textScaleFactor: 1.8,
                    )),
              ),
            ),
          ],
        ));
  }

  void onPressed() {}
}

class NetWorthButton extends StatefulWidget {
  const NetWorthButton({super.key});

  @override
  State<NetWorthButton> createState() => _NetWorthButtonState();
}

class _NetWorthButtonState extends State<NetWorthButton> {
  String netWorth = "1,000,000";
  String symbol = "USD";
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 75,
            child: TextButton(
                onPressed: onPressed,
                style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.black),
                  foregroundColor:
                      MaterialStatePropertyAll<Color>(Colors.white70),
                ),
                child: Text(
                  "$netWorth $symbol",
                  textScaleFactor: 1.8,
                )),
          ),
        ),
      ],
    );
  }

  void onPressed() {
    setState(() {
      if (netWorth == "1,000,000") {
        netWorth = "1,000";
        symbol = "ETH";
      } else {
        netWorth = "1,000,000";
        symbol = "USD";
      }
    });
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

class AssetList extends StatefulWidget {
  const AssetList({super.key});

  @override
  State<AssetList> createState() => _AssetListState();
}

class _AssetListState extends State<AssetList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
