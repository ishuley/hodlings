import 'package:flutter/material.dart';
import 'add_new_asset_screen.dart';
import 'asset_card.dart';

// TODO LIST:
//
// 1) Finish integrating stocks and cash type assets.
// 2) Tear out current styles and replace with proper Flutter themes,
// and add ability to toggle themes (persist it).
// 3) Add the ability to delete AssetCards.
// 4) Add the ability to persist AssetCard list.
// 5) Add the ability to refresh AssetCard list's data.
// 6) Add ability to reload asset lists.
// 7) Add the ability to sort by specific AssetCard elements like total, market
// cap, or alphabetically by ticker. Default it to total. Persist chosen sort
// order.
// 8) Divide the app into many smaller pieces and into appropriate folders.
// 9) This is a minimum viable product. Get a code review from the nice people
// in FlutterDev discord.
// 10) Add daily volume and % change. Give user option for displayed % change
// time frame. Persist it.
// 11) Add support for different vs currencies, and the necessary conversions.
// as well as customized lists of preferred vs currencies that can be toggled
// through by pushing the net worth button.
// 12) Add the ability to back up AssetCard list to the cloud and restore using
// a seed.
// 13) Add a chart to each AssetCard based one the chosen % change time interval.
// Provide option to toggle chart on or off, add to settings, persist it.
// 14) Add the ability to back up settings to the cloud (which should be
// persistent already).
// 15) Add API support for exchanges and brokers where possible.
// 16) Add support for NFTs and scrape GameStops marketplace to support it,
// if necessary and permissible.

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
      // TODO Make this listener update the vsTicker appropriately to the next available vsCurrency when pressed.
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
