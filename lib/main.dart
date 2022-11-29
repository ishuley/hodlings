import 'package:flutter/material.dart';
import 'asset.dart';

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

class AssetList extends StatefulWidget {
  const AssetList({super.key});

  @override
  State<AssetList> createState() => _AssetListState();
}

class _AssetListState extends State<AssetList> {
  List<Asset> assets = [];

  @override
  Widget build(BuildContext context) {
    return Container();
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

class AddNewAssetScreen extends StatefulWidget {
  const AddNewAssetScreen({super.key});

  @override
  State<AddNewAssetScreen> createState() => _AddNewAssetScreenState();
}

class _AddNewAssetScreenState extends State<AddNewAssetScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
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
