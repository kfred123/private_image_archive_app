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
  Stream<Image> readImages() {
    StreamController<Image> streamController = StreamController<Image>();
    streamController.onListen = () => {
          CustomImagePicker.getAllImages.then((images) {
            for (String uri in images.take(2)) {
              streamController.add(new Image.ImageByPath(uri));
            }
            streamController.close();
          })
        };
    /*getExternalStorageDirectory().then((dir) {
        dir.list(recursive: true, followLinks: true).listen((fileSystemEntity) {
          streamController.add(new Image(fileSystemEntity));
        });
    });*/
    Stream<Image> stream = streamController.stream;
    return stream;
  }
}
