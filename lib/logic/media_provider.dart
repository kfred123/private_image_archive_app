import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path/path.dart' as Path;
import 'helper.dart';

abstract class MediaItem {
  String getId();
  String getPath();
  String getName();
  AssetType getMediaType();
  Future<Uint8List> readFileData();
}

class MediaItemDesktop extends MediaItem {
  late FileSystemEntity _entity;

  MediaItemDesktop(FileSystemEntity entity) {
    _entity = entity;
  }

  String getId() {
    return _entity.absolute.path;
  }

  String getPath() {
    return _entity.absolute.path;
  }

  String getName() {
    return _entity.absolute.path.substring(_entity.absolute.parent.path.length);
  }

  AssetType getMediaType() {
    String name = getName();
    String extension = name.substring(name.lastIndexOf('.'));
    AssetType assetType = AssetType.other;
    if(extension == ".png" || extension == ".jpg" || extension == ".jpeg") {
      assetType = AssetType.image;
    } else if(extension == ".mp4") {
      assetType = AssetType.video;
    }
    return assetType;
  }

  Future<Uint8List> readFileData() async {
    return File(getPath()).readAsBytes();
  }
}

class MediaItemMobile extends MediaItem {
  AssetEntity _assetEntity;

  MediaItemMobile(AssetEntity assetEntity) : _assetEntity = assetEntity;

  String getId() {
    return _assetEntity.id;
  }

  String getPath() {
    return Path.join(getString(_assetEntity?.relativePath), _assetEntity.title);
  }

  String getName() {
    return getString(_assetEntity.title);
  }

  AssetType getMediaType() {
    return _assetEntity.type;
  }

  Future<Uint8List> readFileData() async {
    File? file = await _assetEntity.loadFile();
    return await file!.readAsBytes();
  }
}

class MediaProvider {
  Stream<MediaItem> readAllMediaDataFromFolder(String folder) {
    Stream<FileSystemEntity> files = Directory(folder).list(recursive: true);
    return files.map((entity) => new MediaItemDesktop(entity));
  }

  Stream<MediaItem> readAllMediaDataFromPhone() async* {
    List<AssetPathEntity> assetPaths = await PhotoManager.getAssetPathList();
    for(AssetPathEntity assetPath in assetPaths) {
      List<MediaItem> items;
      int page = 0;
      int count = 0;
      do {
        items = (await assetPath.getAssetListPaged(page: page, size: 100))
            .map((e) => new MediaItemMobile(e)).toList();
        for(MediaItem mediaItem in items/*.where((element) => element.getMediaType() == AssetType.video)*/) {
          yield mediaItem;
          count++;
          //if(count > 99) {
          //  return;
          //}
        }
        page++;
      } while(items.isNotEmpty);
    }
  }
}