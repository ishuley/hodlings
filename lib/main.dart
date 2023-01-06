import 'package:flutter/material.dart';
import 'add_new_asset_screen.dart';
import 'asset_card.dart';

void main() => runApp(
      MaterialApp(
        routes: {
          '/': (context) => const MainScreen(),
        },
      ),
    );

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double netWorth = 0;
  String vsTicker = "USD";
  List<AssetCard> assetList = [];

  void onNetWorthButtonPressed() {
    setState(() {
      // TODO make this screen update the vsTicker appropriately
    });
  }

  Future<void> addNewAssetScreen() async {
    final AssetCard? newAssetCard = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddNewAssetScreen(),
        ));
    if (newAssetCard != null) {
      setState(() {
        incrementNetWorth(newAssetCard.totalValue);
        addToAssetList(newAssetCard);
      });
    }
  }

  void incrementNetWorth(double incrementAmount) {
    netWorth += incrementAmount;
  }

  void addToAssetList(AssetCard? newAssetCard) {
    assetList.add(newAssetCard!);
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
                  netWorth: netWorth.toStringAsFixed(2),
                  vsTicker: vsTicker,
                  onNetWorthClickCallback: onNetWorthButtonPressed,
                ),
                Expanded(
                  child: AssetDisplay(
                    assetList: assetList,
                  ),
                ),
                // AssetCard(asset: Crypto("Ethereum", 20), vsTicker: "USD"),
                AddNewAssetButton(addNewAssetCallback: addNewAssetScreen),
              ],
            ),
          ),
        ));
  }
}

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Colors.grey[850],
        child: ListView(
          children: const [],
        ));
  }
}

class NetWorthButton extends StatelessWidget {
  final String netWorth;
  final String vsTicker;
  final VoidCallback onNetWorthClickCallback;
  const NetWorthButton(
      {super.key,
      required this.netWorth,
      required this.vsTicker,
      required this.onNetWorthClickCallback});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 75,
            child: TextButton(
                onPressed: onNetWorthClickCallback,
                style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.black),
                  foregroundColor:
                      MaterialStatePropertyAll<Color>(Colors.white),
                ),
                child: Text(
                  "$netWorth $vsTicker",
                  textScaleFactor: 1.8,
                )),
          ),
        ),
      ],
    );
  }
}

class AssetDisplay extends StatelessWidget {
  final List<AssetCard> assetList;

  const AssetDisplay({super.key, required this.assetList});

  @override
  Widget build(BuildContext context) {
    if (assetList.isNotEmpty) {
      return ListView.builder(
          itemCount: assetList.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Colors.white70,
              child: assetList[index],
            );
          });
    }
    return const Align(
      alignment: Alignment.center,
      child: Text(
        "No assets entered yet",
        style: TextStyle(
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AddNewAssetButton extends StatefulWidget {
  final VoidCallback addNewAssetCallback;

  const AddNewAssetButton({super.key, required this.addNewAssetCallback});

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
                onPressed: widget.addNewAssetCallback,
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
        ],
      ),
    );
  }
}
