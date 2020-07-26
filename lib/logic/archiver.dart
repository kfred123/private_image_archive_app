import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:private_image_archive_app/logic/server.dart';
import 'package:private_image_archive_app/logic/settings_provider.dart';
import 'package:synchronized/synchronized.dart';

import 'image_provider.dart' as Logic;

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
    // ToDo testen ob die queue hier richtig funktioniert
    Lock lock = new Lock();
    lock.synchronized(() async {
      List<Logic.Image> nextImages = images.take(maxProcessingAtOnce - currentlyProcessing);
      for(Logic.Image image in nextImages) {
        images.remove(image);
        currentlyProcessing++;
        uploadImage(image);
      }
    });
  }

  void uploadImage(Logic.Image image) async {
    File imageFile = File(image.getPath());
    Uint8List imageData = imageFile.readAsBytesSync();
    String fileName = Uri.parse(image.getPath()).pathSegments.last;
    // ToDo Hash berechnen und prüfen mit Server und ggf. Upload überspringen
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
    Lock lock = new Lock();
    lock.synchronized(() async {
      currentlyProcessing--;
    });
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