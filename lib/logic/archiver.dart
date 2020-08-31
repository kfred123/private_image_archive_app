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
  int duplicateInPhone = 0;

  int currentlyProcessing = 0;
  List<Logic.Image> images = new List();
  Set<String> processedHashes = new Set();

  void _onDoneArchivingCallBack;

  ServerAccess _serverAccess;

  Archiver(ServerAccess serverAccess) {
    _serverAccess = serverAccess;
  }

  void archiveImages(Iterable<Logic.Image> images) {
    reset();
    totalImages = images.length;
    this.images.addAll(images);
    processAll();
  }

  bool isDoneArchiving() {
    return processedImages >= totalImages;
  }

  void processAll() async {
    while(images.isNotEmpty) {
      List<Future> uploads = new List();
      while(uploads.length < maxProcessingAtOnce && images.isNotEmpty) {
        Logic.Image image = images.removeLast();
        String hash = calcImageHash(image);
        if(!processedHashes.contains(hash)) {
          processedHashes.add(hash);
          uploads.add(uploadImage(image));
          changeCurrentlyProcessing(1);
        } else {
          countSkippedImage();
          processedImages++;
          duplicateInPhone++;
        }
      }
      for(Future future in uploads) {
        await future;
      }
    }
    int x = 0;
  }

  void changeCurrentlyProcessing(int change) {
    Lock lock = new Lock();
    lock.synchronized(() async {
      currentlyProcessing += change;
    });
  }

  void countSkippedImage() {
    Lock lock = new Lock();
    lock.synchronized(() async {
      skippedImages++;
    });
  }

  String calcImageHash(Logic.Image image) {
    Uint8List imageData = image.readImageData();
    String hash = sha256.convert(imageData).toString();
    return hash;
  }

  Future uploadImage(Logic.Image image) async {
    String hash = calcImageHash(image);
    UploadImageResult uploadResult;
    if (await _serverAccess.checkImageExistanceByHash(hash)) {
      uploadResult = UploadImageResult.AlreadyPresent;
    } else {
      String fileName = Uri.parse(image.getPath()).pathSegments.last;
      uploadResult = await _serverAccess.uploadImage(image.readImageData(), fileName);
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
        countSkippedImage();
        Logging.logInfo(sprintf("Skipping %s", [image.getPath()]));
        break;
    }
    changeCurrentlyProcessing(-1);
  }

  void reset() {
    totalImages = 0;
    processedImages = 0;
    addedImages = 0;
    skippedImages = 0;
    failedUploads = 0;
    currentlyProcessing = 0;
    duplicateInPhone = 0;
    images.clear();
    processedHashes.clear();
  }
}
