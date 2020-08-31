import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:custom_image_picker/custom_image_picker.dart';

class Image {
  String _path;
  Uint8List _imageData;

  Image(FileSystemEntity fileSystemEntity) {
    _path = fileSystemEntity.path;
  }

  Image.ImageByPath(String path) {
    _path = path;
  }

  String getPath() {
    return _path;
  }

  Uint8List readImageData() {
    if(_imageData == null)  {
      File imageFile = File(getPath());
      _imageData = imageFile.readAsBytesSync();
    }
    return _imageData;
  }
}

class ImageProvider {
  Future<List<Image>> readImages() async {
    List<dynamic> images = await CustomImagePicker.getAllImages;
    List<Image> result = new List<Image>(images.length);
    for(String name in images) {
      if(name.endsWith("mp4")) {
        int x = 0;
      }
    }
    images.asMap().forEach((i, uri) {
      result[i] = new Image.ImageByPath(uri);
    });
    return result;
  }
}
