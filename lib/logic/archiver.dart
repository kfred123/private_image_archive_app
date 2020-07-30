import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:private_image_archive_app/logic/server.dart';
import 'package:private_image_archive_app/logic/settings_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:crypto/crypto.dart';
import 'image_provider.dart' as Logic;
import 'package:private_image_archive_app/logging.dart';
import 'package:sprintf/sprintf.dart';

class Archiver {
  final int maxProcessingAtOnce = 10;

  int totalImages = 0;
  int processedImages = 0;
  int addedImages = 0;
  int skippedImages = 0;
  int failedUploads = 0;

  int currentlyProcessing = 0;
  List<Logic.Image> images = new List();

  void _onDoneArchivingCallBack;

  ServerAccess _serverAccess;

  Archiver(ServerAccess serverAccess) {
    _serverAccess = serverAccess;
  }

  void archiveImages(Iterable<Logic.Image> images) {
    reset();
    totalImages = images.length;
    this.images.addAll(images);
    processNext();
  }

  bool isDoneArchiving() {
    return processedImages >= totalImages;
  }

  void processNext() {
    Lock lock = new Lock();
    lock.synchronized(() async {
      Set<Logic.Image> nextImages =
          images.take(maxProcessingAtOnce - currentlyProcessing).toSet();
      for (Logic.Image image in nextImages) {
        images.remove(image);
        changeCurrentlyProcessing(1);
        uploadImage(image);
      }
    });
  }

  void changeCurrentlyProcessing(int change) {
    Lock lock = new Lock();
    lock.synchronized(() async {
      currentlyProcessing += change;
    });
  }

  void uploadImage(Logic.Image image) async {
    File imageFile = File(image.getPath());
    Uint8List imageData = imageFile.readAsBytesSync();
    String hash = sha256.convert(imageData).toString();
    UploadImageResult uploadResult;
    if (await _serverAccess.checkImageExistanceByHash(hash)) {
      uploadResult = UploadImageResult.AlreadyPresent;
    } else {
      String fileName = Uri.parse(image.getPath()).pathSegments.last;
      uploadResult = await _serverAccess.uploadImage(imageData, fileName);
    }
    processedImages++;
    switch (uploadResult) {
      case UploadImageResult.Failed:
        failedUploads++;
        break;
      case UploadImageResult.Added:
        addedImages++;
        break;
      case UploadImageResult.AlreadyPresent:
        skippedImages++;
        Logging.logInfo(sprintf("Skipping %s", [image.getPath()]));
        break;
    }
    changeCurrentlyProcessing(-1);
    processNext();
  }

  void reset() {
    totalImages = 0;
    processedImages = 0;
    addedImages = 0;
    skippedImages = 0;
    failedUploads = 0;
    currentlyProcessing = 0;
    images.clear();
  }
}
