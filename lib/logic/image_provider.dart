import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:custom_image_picker/custom_image_picker.dart';

class Image {
  String _path;

  Image(FileSystemEntity fileSystemEntity) {
    _path = fileSystemEntity.path;
  }

  Image.ImageByPath(String path) {
    _path = path;
  }

  String getPath() {
    return _path;
  }
}

class ImageProvider {
  Future<List<Image>> readImages() async {
    List<dynamic> images = await CustomImagePicker.getAllImages;
    List<Image> result = new List<Image>(images.length);
    images.asMap().forEach((i, uri) {
      result[i] = new Image.ImageByPath(uri);
    });
    return result;
  }
}
