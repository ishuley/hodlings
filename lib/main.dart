import 'package:flutter/material.dart';
import 'package:hodlings/themes.dart';
import 'add_new_asset_screen/add_new_asset_screen.dart';
import 'asset_card.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
// ## Add more themes

void main() => runApp(const HODLings());

class HODLings extends StatefulWidget {
  const HODLings({super.key});

  @override
  State<HODLings> createState() => _HODLingsState();
}

class _HODLingsState extends State<HODLings> {
  ThemeMode currentTheme = ThemeMode.system;
  String currentThemeDescription = 'System theme';

  @override
  void initState() {
    super.initState();
    initTheme();
  }

  Future<void> initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedTheme = prefs.getString('lastTheme');
    if (storedTheme != null) {
      setTheme(storedTheme);
    }
  }

  void setTheme(String newTheme) {
    setState(() {
      currentTheme = getThemeFromChoice(newTheme);
      currentThemeDescription = newTheme;
    });
  }

  void onThemeChanged(String chosenTheme) async {
    setTheme(chosenTheme);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastTheme', currentThemeDescription);
  }

  ThemeMode getThemeFromChoice(String themeChoice) {
    switch (themeChoice) {
      case 'Dark theme':
        return ThemeMode.dark;
      case 'Light theme':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => MainScreen(
              onThemeChangedCallback: onThemeChanged,
              currentThemeDescription: currentThemeDescription,
            ),
      },
      title: 'HODLings',
      themeMode: currentTheme,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
    );
  }
}

class MainScreen extends StatefulWidget {
  final ValueChanged<String> onThemeChangedCallback;
  final String currentThemeDescription;

  const MainScreen({
    super.key,
    required this.onThemeChangedCallback,
    required this.currentThemeDescription,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double netWorth = 0;
  String vsTicker = 'USD';
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
      ),
    );
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

  void decrementNetWorth(double decrementAmount) {
    netWorth -= decrementAmount;
  }

  void addToAssetList(AssetCard? newAssetCard) {
    assetList.add(newAssetCard!);
  }

  void deleteAssetCard(int index) {
    setState(() {
      decrementNetWorth(assetList[index].totalValue);
      assetList.removeAt(index);
    });
  }

  void editQuantity(int index) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'HODLings',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      drawer: DrawerMenu(
        onThemeChangedCallback: widget.onThemeChangedCallback,
        currentThemeDescription: widget.currentThemeDescription,
      ),
      body: Center(
        child: Column(
          children: [
            NetWorthButton(
              netWorth: NumberFormat('###,###,###,###,###,###', 'en_US')
                  .format(netWorth),
              vsTicker: vsTicker,
              onNetWorthClickCallback: onNetWorthButtonPressed,
            ),
            Expanded(
              child: AssetDisplay(
                assetList: assetList,
                deleteAssetCardCallback: deleteAssetCard,
                editAssetCardQuantityCallback: editQuantity,
              ),
            ),
            AddNewAssetButton(
              addNewAssetCallback: addNewAssetScreen,
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerMenu extends StatelessWidget {
  final ValueChanged<String> onThemeChangedCallback;
  final String currentThemeDescription;
  const DrawerMenu({
    super.key,
    required this.onThemeChangedCallback,
    required this.currentThemeDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 0, 10),
            child: Text(
              'Theme:',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          ),
          ThemeChoiceDropdown(
            onThemeChangedCallback: onThemeChangedCallback,
            currentThemeDescription: currentThemeDescription,
          ),
        ],
      ),
    );
  }
}

class ThemeChoiceDropdown extends StatefulWidget {
  final ValueChanged<String> onThemeChangedCallback;
  final String currentThemeDescription;

  const ThemeChoiceDropdown({
    super.key,
    required this.onThemeChangedCallback,
    required this.currentThemeDescription,
  });

  @override
  State<ThemeChoiceDropdown> createState() => _ThemeChoiceDropdownState();
}

class _ThemeChoiceDropdownState extends State<ThemeChoiceDropdown> {
  late String currentThemeChoice;

  @override
  Widget build(BuildContext context) {
    currentThemeChoice = widget.currentThemeDescription;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: DropdownButton<String>(
        isExpanded: true,
        dropdownColor: Theme.of(context).primaryColor,
        onChanged: ((String? selectedTheme) {
          currentThemeChoice = selectedTheme!;
          widget.onThemeChangedCallback(currentThemeChoice);
        }),
        value: currentThemeChoice,
        items: const ['System theme', 'Dark theme', 'Light theme']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}

class NetWorthButton extends StatelessWidget {
  final String netWorth;
  final String vsTicker;
  final VoidCallback onNetWorthClickCallback;
  const NetWorthButton({
    super.key,
    required this.netWorth,
    required this.vsTicker,
    required this.onNetWorthClickCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 75,
            child: TextButton(
              onPressed: onNetWorthClickCallback,
              child: Text(
                '$netWorth $vsTicker',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AssetDisplay extends StatefulWidget {
  final List<AssetCard> assetList;
  final ValueChanged<int> deleteAssetCardCallback;
  final ValueChanged<int> editAssetCardQuantityCallback;

  const AssetDisplay({
    super.key,
    required this.assetList,
    required this.deleteAssetCardCallback,
    required this.editAssetCardQuantityCallback,
  });

  @override
  State<AssetDisplay> createState() => _AssetDisplayState();
}

class _AssetDisplayState extends State<AssetDisplay> {
  Offset _tapPosition = Offset.zero;
  int tappedCardIndex = 0;
  String contextChoice = '';

  @override
  Widget build(BuildContext context) {
    if (widget.assetList.isNotEmpty) {
      return ListView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: widget.assetList.length,
        itemBuilder: (BuildContext newContext, int index) {
          return GestureDetector(
            onTapDown: (details) {
              _getTapPosition(details, context);
              _storeIndex(index);
            },
            onLongPress: () {
              _showContextMenu(context);
            },
            child: Card(
              child: widget.assetList[index],
            ),
          );
        },
      );
    }
    return const Align(
      alignment: Alignment.center,
      child: Text(
        'No assets entered yet',
        textAlign: TextAlign.center,
      ),
    );
  }

  void _getTapPosition(TapDownDetails details, BuildContext context) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    _tapPosition = referenceBox.globalToLocal(details.globalPosition);
  }

  void _storeIndex(int index) {
    tappedCardIndex = index;
  }

  void _showContextMenu(BuildContext context) async {
    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();

    String? userChoice = await _showMenu(context, overlay);
    if (userChoice != null) {
      contextChoice = userChoice;
    }
    _executeChosenAction();
  }

  Future<String?> _showMenu(BuildContext context, RenderObject? overlay) async {
    String? userChoice = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(_tapPosition.dx + 140, _tapPosition.dy + 85, 30, 30),
        Rect.fromLTWH(
          0,
          0,
          overlay!.paintBounds.size.width,
          overlay.paintBounds.size.height,
        ),
      ),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit quantity'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete asset'),
        ),
      ],
    );
    return userChoice;
  }

  void _executeChosenAction() {
    if (contextChoice == 'delete') {
      widget.deleteAssetCardCallback(tappedCardIndex);
    }
    if (contextChoice == 'edit') {
      widget.editAssetCardQuantityCallback(tappedCardIndex);
    }
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
                child: Icon(
                  Icons.add,
                  size: Theme.of(context).iconTheme.size,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
