import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:private_image_archive_app/db/archived_item.dart';
import 'package:private_image_archive_app/db/database.dart';
import 'package:private_image_archive_app/logic/server.dart';
import 'package:private_image_archive_app/logic/settings_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:crypto/crypto.dart';
import 'media_provider.dart' as Logic;
import 'package:private_image_archive_app/logging.dart';
import 'package:sprintf/sprintf.dart';

class Archiver {
  final int maxProcessingAtOnce = 10;
  List<Future> _currentUploads = new List();

  int totalItems = 0;
  int processedItems = 0;
  int addedItems = 0;
  int skippedItems = 0;
  int failedItems = 0;
  int duplicateInPhone = 0;

  int currentlyProcessing = 0;
  List<Logic.MediaItem> items = new List();
  Set<String> processedHashes = new Set();

  void _onDoneArchivingCallBack;

  ServerAccess _serverAccess;
  DataBaseConnection _dataBaseConnection;

  Archiver(ServerAccess serverAccess, DataBaseConnection dataBaseConnection) {
    _serverAccess = serverAccess;
    _dataBaseConnection = dataBaseConnection;
  }

  void archiveMediaItems(Iterable<Logic.MediaItem> items) {
    reset();
    totalItems = items.length;
    this.items.addAll(items);
    processAll();
  }

  bool isDoneArchiving() {
    return processedItems >= totalItems;
  }

  void processAll() async {
    processNext();
  }

  void processNext() {
    Lock lock = new Lock();
    lock.synchronized(() async {
      while (_currentUploads.length < maxProcessingAtOnce && items.isNotEmpty) {
        Logic.MediaItem mediaItem = items.removeLast();
        String hash = ""; //calcMediaItemHash(mediaItem);
        if (true || !processedHashes.contains(hash)) {
          processedHashes.add(hash);
          Future future = uploadMediaItem(mediaItem);
          _currentUploads.add(future);
          future.then((result) {
            _currentUploads.remove(future);
            processNext();
          });
          changeCurrentlyProcessing(1);
        } else {
          countSkippedImage();
          processedItems++;
          duplicateInPhone++;
        }
      }
    });
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
      skippedItems++;
    });
  }

  Future<bool> isMediaItemAlreadyArchived(Logic.MediaItem mediaItem) async {
    String col = ArchivedItem.COL_MEDIA_ITEM_PATH;
    List<ArchivedItem> items = await _dataBaseConnection.query(() => ArchivedItem(),
        where: "$col=?", whereArgs: [mediaItem.getPath()]);
    return items.isNotEmpty;
  }

  void setMediaItemArchived(Logic.MediaItem mediaItem) {
    ArchivedItem archivedItem = ArchivedItem();
    archivedItem.mediaItemPath = mediaItem.getPath();
    archivedItem.archivedDate = DateTime.now();
    _dataBaseConnection.updateOrInsert(archivedItem);
  }

  Future uploadMediaItem(Logic.MediaItem mediaItem) async {
    UploadResult uploadResult;
    if(await isMediaItemAlreadyArchived(mediaItem)) {
      uploadResult = UploadResult.AlreadyArchived;
    } else {
      if(mediaItem.getMediaType() == AssetType.image) {
        uploadResult = await uploadImage(mediaItem);
      } else {
        uploadResult = await uploadVideo(mediaItem);
      }
      if(uploadResult == UploadResult.Added) {
        setMediaItemArchived(mediaItem);
      } else if(uploadResult == UploadResult.AlreadyArchived){
        countSkippedImage();
      }
    }

    processedItems++;
    switch (uploadResult) {
      case UploadResult.Failed:
        failedItems++;
        break;
      case UploadResult.Added:
        addedItems++;
        break;
      case UploadResult.AlreadyArchived:
        countSkippedImage();
        Logging.logInfo(sprintf("Skipping %s", [mediaItem.getPath()]));
        break;
    }
    changeCurrentlyProcessing(-1);
  }

  Future<UploadResult> uploadVideo(Logic.MediaItem video) async {
    String fileName = Uri.parse(video.getPath()).pathSegments.last;
    return await _serverAccess.uploadVideo(await video.readFileData(), fileName);
  }

  Future<UploadResult> uploadImage(Logic.MediaItem image) async {
    String fileName = Uri.parse(image.getPath()).pathSegments.last;
    return await _serverAccess.uploadImage(await image.readFileData(), fileName);
  }

  void reset() {
    totalItems = 0;
    processedItems = 0;
    addedItems = 0;
    skippedItems = 0;
    failedItems = 0;
    currentlyProcessing = 0;
    duplicateInPhone = 0;
    items.clear();
    processedHashes.clear();
    _currentUploads.clear();
  }
}
