import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaItem {
  AssetEntity _assetEntity;

  MediaItem(AssetEntity assetEntity) {
    this._assetEntity = assetEntity;
  }

  String getPath() {
    return _assetEntity.relativePath;
  }

  AssetType getMediaType() {
    return _assetEntity.type;
  }

  Future<Uint8List> readFileData() async {
    File file = await _assetEntity.loadFile();
    return await file.readAsBytes();
  }
}

class MediaProvider {
  Future<List<MediaItem>> readAllMediaData() async {
    List<MediaItem> result = List.empty();
    List<AssetPathEntity> assetPaths = await PhotoManager.getAssetPathList();
    for(AssetPathEntity assetPath in assetPaths) {
      result = (await assetPath.getAssetListPaged(page: 0, size: 100)).map((e) => new MediaItem(e));
    }
    return result;
  }
}
