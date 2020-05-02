import 'dart:io';
import 'dart:typed_data';
import 'package:private_image_archive_app/logic/server.dart';
import 'package:private_image_archive_app/logic/settings_provider.dart';

import 'image_provider.dart';

class Archiver {
  int totalImages = 0;
  int processedImages = 0;
  int addedImages = 0;
  int skippedImages = 0;

  ServerAccess _serverAccess;

  Archiver(ServerAccess serverAccess) {
    _serverAccess = serverAccess;
  }

  void archiveImages(Stream<Image> imageStream) {
    reset();
    imageStream.listen(this.enqueueImage);
  }

  void enqueueImage(Image image) async {
    totalImages = totalImages + 1;
    File imageFile = File(image.getPath());
    Uint8List imageData = imageFile.readAsBytesSync();
    bool uploadResult = await _serverAccess.uploadImage(imageData);
    processedImages++;
    if(uploadResult) {
      addedImages++;
    } else {
      skippedImages++;
    }
  }

  void reset() {
    int totalImages = 0;
    int processedImages = 0;
    int addedImages = 0;
    int skippedImages = 0;
  }
}