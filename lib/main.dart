import 'package:flutter/material.dart';
import 'add_new_asset_screen.dart';
import 'asset_card.dart';

// TODO LIST:

// 3) Add the ability to delete AssetCards.
// 4) Add the ability to persist AssetCard list.
// 5) Add the ability to refresh AssetCard list's data.
// 6) Add ability to reload asset lists. Limit the frequency that API calls can be made.
// 7) Add the ability to sort by specific AssetCard elements like total, market
// cap, or alphabetically by ticker. Default it to total. Persist chosen sort
// order.
// 7.5) Add attributiona to CoinGecko and FinancialModelingPrep.
// 8) Divide the app into many smaller pieces and into appropriate folders.
// 9) Finish blockchain based address lookup.
// 10) Add daily volume and % change. Give user option for displayed % change
// time frame. Persist it.
// 10.5) Add option to toggle whether market cap is described in words or numbers. Persist it.
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
// 18) Add precious metal support.

void main() => runApp(
      MaterialApp(
        routes: {
          '/': (context) => const MainScreen(),
        },
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.grey,
          useMaterial3: true,
        ),
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
          centerTitle: true,
        ),
        drawer: const DrawerMenu(),
        body: Center(
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
              AddNewAssetButton(addNewAssetCallback: addNewAssetScreen),
            ],
          ),
        ));
  }
}

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              child: Text("$netWorth $vsTicker",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  )),
            ),
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
          physics: const ClampingScrollPhysics(),
          itemCount: assetList.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: assetList[index],
            );
          });
    }
    return const Align(
      alignment: Alignment.center,
      child: Text(
        "No assets entered yet",
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
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
