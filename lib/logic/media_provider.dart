import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_multimedia_picker/data/MediaFile.dart';
import 'package:flutter_multimedia_picker/fullter_multimedia_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:custom_image_picker/custom_image_picker.dart';

class MediaItem {
  String _path;
  Uint8List _data;
  MediaType _type;

  MediaItem(FileSystemEntity fileSystemEntity) {
    _path = fileSystemEntity.path;
  }

  MediaItem.ByMediaFile(MediaFile mediaFile) {
    _path = mediaFile.path;
    _type = mediaFile.type;
  }

  String getPath() {
    return _path;
  }

  MediaType getMediaType() {
    return _type;
  }

  Uint8List readFileData() {
    if(_data == null)  {
      File imageFile = File(getPath());
      _data = imageFile.readAsBytesSync();
    }
    return _data;
  }
}

class MediaProvider {
  Future<List<MediaItem>> readAllMediaData() async {
    List<MediaFile> mediaFiles = await FlutterMultiMediaPicker.getAll();
    List<MediaItem> result = new List<MediaItem>();
    for(MediaFile mediaFile in mediaFiles) {
      result.add(MediaItem.ByMediaFile(mediaFile));
    }
    return result;
  }
}
