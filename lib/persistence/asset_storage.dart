import 'dart:convert';
import 'dart:io';
import 'package:hodlings/persistence/asset_data_item.dart';
import 'package:hodlings/persistence/asset_dropdown_item.dart';
import 'package:path_provider/path_provider.dart';
import '../asset.dart';

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
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> get _stockAssetListFile async {
    final path = await _localPath;
    return File('$path/stockAssetList.json');
  }

  Future<File> get _cryptoAssetListFile async {
    final path = await _localPath;
    return File('$path/cryptoAssetList.json');
  }

  Future<File> get _cashAssetListFile async {
    final path = await _localPath;
    return File('$path/cashAssetList.json');
  }

  Future<File> get _stockAssetDataFile async {
    final path = await _localPath;
    return File('$path/stockAssetData.json');
  }

  Future<File> get _cryptoAssetDataFile async {
    final path = await _localPath;
    return File('$path/cryptoAssetData.json');
  }

  Future<File> get _cashAssetDataFile async {
    final path = await _localPath;
    return File('$path/cashAssetData.json');
  }

  Future<List<AssetDataItem>> readAssetData(AssetType assetType) async {
    File assetDataFile = await chooseAssetDataFile(assetType);
    if (await assetDataFile.exists()) {
      List decodedAssetData = await decodeJsonFromFile(assetDataFile);
      List<AssetDataItem> assetData = [];
      for (Map<String, dynamic> assetDataItem in decodedAssetData) {
        assetData.add(AssetDataItem.fromJson(assetDataItem));
      }
      return assetData;
    }
    return [];
  }

  Future<void> writeAssetData(
    List<AssetDataItem> assetData,
    AssetType assetType,
  ) async {
    deleteAssetDataFile(assetType);
    String encodedAssetData = jsonEncode(assetData);
    File assetDatafile = await chooseAssetDataFile(assetType);
    await assetDatafile.writeAsString(encodedAssetData);
  }

  Future<void> writeAssetList(
    List<AssetDropdownItem> assetList,
    AssetType assetType,
  ) async {
    deleteAssetListFile(assetType);
    List<String> assetListAsString = [];
    for (AssetDropdownItem assetDropdownItem in assetList) {
      assetListAsString.add(assetDropdownItem.assetDropdownString);
    }
    String encodedAssetList = jsonEncode(assetListAsString);
    File assetListFile = await chooseAssetListFile(assetType);
    await assetListFile.writeAsString(encodedAssetList);
  }

  Future<List<AssetDropdownItem>> readAssetListFile(
    AssetType assetType,
  ) async {
    File assetListFile = await chooseAssetListFile(assetType);
    if (await assetListFile.exists()) {
      List<dynamic> decodedAssetList = await decodeJsonFromFile(assetListFile);
      List<AssetDropdownItem> assetList = [];
      for (String jsonElement in decodedAssetList) {
        assetList.add(AssetDropdownItem(jsonElement));
      }
      return assetList;
    }
    return [];
  }

  Future<List<dynamic>> decodeJsonFromFile(
    File fileToReadAndDecode,
  ) async {
    List<dynamic> decodedAssetList =
        jsonDecode(await fileToReadAndDecode.readAsString());
    return decodedAssetList;
  }

  Future<void> deleteAssetListFile(AssetType assetType) async {
    File assetListFile = await chooseAssetListFile(assetType);
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

  Future<File> chooseAssetListFile(AssetType assetType) async {
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
