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
  int failedUploads = 0;

  void _onDoneArchivingCallBack;

  ServerAccess _serverAccess;

  Archiver(ServerAccess serverAccess) {
    _serverAccess = serverAccess;
  }

  void archiveImages(Iterable<Image> images) {
    reset();
    totalImages = images.length;
    for(Image image in images) {
      enqueueImage(image);
    }
  }

  bool isDoneArchiving() {
    return processedImages >= totalImages;
  }

  void enqueueImage(Image image) async {
    File imageFile = File(image.getPath());
    Uint8List imageData = imageFile.readAsBytesSync();
    String fileName = Uri.parse(image.getPath()).pathSegments.last;
    UploadImageResult uploadResult = await _serverAccess.uploadImage(imageData, fileName);
    processedImages++;
    switch(uploadResult) {
      case UploadImageResult.Failed:
        failedUploads++;
        break;
      case UploadImageResult.Added:
        addedImages++;
        break;
      case UploadImageResult.AlreadyPresent:
        skippedImages++;
        break;
    }
  }

  void reset() {
    totalImages = 0;
    processedImages = 0;
    addedImages = 0;
    skippedImages = 0;
    failedUploads = 0;
  }
}