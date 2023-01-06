import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'asset.dart';

/// Presistent storage for the lists of selectable assets.
///
/// The [DropdownMenuItem]s used by [AssetDropdown] come from an API call,
/// which is expensive for a poor dev like me. I choose to make the API calls
/// once, then provide a [DrawerMenu.RefreshAssetsButton] to let the user
/// manually refresh them in the event a new security comes along that is not
/// yet listed. This class encapsulates the necessary persistent storage logic.
///
class AssetStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _stockAssetListFile async {
    final path = await _localPath;
    return File('$path/stockAssetList.txt');
  }

  Future<File> get _cryptoAssetListFile async {
    final path = await _localPath;
    return File('$path/cryptoAssetList.txt');
  }

  Future<File> get _cashAssetListFile async {
    final path = await _localPath;
    return File('$path/cashAssetList.txt');
  }

  Future<File> get _stockAssetDataFile async {
    final path = await _localPath;
    return File('$path/stockAssetData.txt');
  }

  Future<File> get _cryptoAssetDataFile async {
    final path = await _localPath;
    return File('$path/cryptoAssetData.txt');
  }

  Future<File> get _cashAssetDataFile async {
    final path = await _localPath;
    return File('$path/cashAssetData.txt');
  }

  Future<List<String>> readAssetList(AssetType assetType) async {
    try {
      final File file = await chooseAssetFile(assetType);
      return await file.readAsLines();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, String>>> readDataList(AssetType assetType) async {
    List<Map<String, String>> storedDataList = [];
    try {
      final File file = await chooseAssetDataFile(assetType);
      List<String> dataFileList = await file.readAsLines();
      for (String lineRead in dataFileList) {
        List<String> splitLine = lineRead.split(";");
        Map<String, String> dataEntry = {
          splitLine[0]: splitLine[1],
          splitLine[2]: splitLine[3],
          splitLine[4]: splitLine[5]
        };
        storedDataList.add(dataEntry);
      }
      return storedDataList;
    } catch (e) {
      return [];
    }
  }

  Future<void> writeAssetData(List<Map<String, String>> newAssetDataMapList,
      AssetType assetType) async {
    File file = await chooseAssetDataFile(assetType);
    deleteAssetDataFile(assetType);
    for (Map<String, String> assetDataMap in newAssetDataMapList) {
      assetDataMap.forEach(
        (dataType, dataValue) async {
          file = await file.writeAsString("$dataType;$dataValue;",
              mode: FileMode.append);
        },
      );
      file = await file.writeAsString('\n', mode: FileMode.append);
    }
  }

  Future<void> writeAssetList(
      List<String> assetList, AssetType assetType) async {
    File file = await chooseAssetFile(assetType);

    for (String assetTickerAndName in assetList) {
      file = await file.writeAsString("$assetTickerAndName\n",
          mode: FileMode.append);
    }
  }

  Future<void> deleteAssetListFile(AssetType assetType) async {
    File assetListFile = await chooseAssetFile(assetType);
    if (await assetListFile.exists()) {
      assetListFile.delete();
    }
  }

  Future<void> deleteAssetDataFile(AssetType assetType) async {
    File assetDataFile = await chooseAssetDataFile(assetType);
    if (await assetDataFile.exists()) {
      assetDataFile.delete();
    }
  }

  Future<File> chooseAssetFile(AssetType assetType) async {
    switch (assetType) {
      case AssetType.stock:
        return await _stockAssetListFile;
      case AssetType.crypto:
        return await _cryptoAssetListFile;
      case AssetType.cash:
        return await _cashAssetListFile;
    }
  }

  Future<File> chooseAssetDataFile(AssetType assetType) async {
    switch (assetType) {
      case AssetType.stock:
        return await _stockAssetDataFile;
      case AssetType.crypto:
        return await _cryptoAssetDataFile;
      case AssetType.cash:
        return await _cashAssetDataFile;
    }
  }
}
