import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path/path.dart' as Path;

class MediaItem {
  AssetEntity _assetEntity;

  MediaItem(AssetEntity assetEntity) {
    this._assetEntity = assetEntity;
  }

  String getId() {
    return _assetEntity.id;
  }
  String getPath() {
    return Path.join(_assetEntity.relativePath, _assetEntity.title);
  }

  String getName() {
    return _assetEntity.title;
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
  Stream<MediaItem> readAllMediaData() async* {
    List<AssetPathEntity> assetPaths = await PhotoManager.getAssetPathList();
    for(AssetPathEntity assetPath in assetPaths) {
      List<MediaItem> items;
      int page = 0;
      do {
        items = (await assetPath.getAssetListPaged(page: page, size: 100))
            .map((e) => new MediaItem(e)).toList();
        for(MediaItem mediaItem in items) {
          yield mediaItem;
        }
        page++;
      } while(items.isNotEmpty);
    }
  }
}