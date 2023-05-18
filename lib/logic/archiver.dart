import 'dart:collection';
import 'dart:io';
import 'package:pool/pool.dart';
import 'dart:async';
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
  final int maxProcessingAtOnce = 1;

  int totalItems = 0;
  int processedItems = 0;
  int addedItems = 0;
  int skippedItems = 0;
  int failedItems = 0;
  int duplicateInPhone = 0;

  Queue<Logic.MediaItem> queue = new Queue();
  Set<String> processedHashes = new Set();
  late Pool _pool;
  List<String> failedItemList = List.empty(growable: true);

  void _onDoneArchivingCallBack;

  ServerAccess _serverAccess;
  DataBaseConnection _dataBaseConnection;

  Archiver(ServerAccess serverAccess, DataBaseConnection dataBaseConnection)
      : _serverAccess = serverAccess,
        _dataBaseConnection = dataBaseConnection;

  void archiveMediaItems(Stream<Logic.MediaItem> items) async {
    reset();
    _pool = new Pool(maxProcessingAtOnce, timeout: Duration(seconds: 60));
    items.listen((item) {
      Lock lock = new Lock();
      lock.synchronized(() async {
        queue.add(item);
        totalItems++;
      });
      _pool.withResource(() => uploadMediaItem(item));
    });
  }

  void cancel() {
    _pool.close();
    reset();
  }

  bool isDoneArchiving() {
    return totalItems > 0 && processedItems >= totalItems;
  }

  void countSkippedImage() {
    Lock lock = new Lock();
    lock.synchronized(() async {
      skippedItems++;
    });
  }

  Future<bool> isMediaItemAlreadyArchived(Logic.MediaItem mediaItem) async {
    Iterable<ArchivedItem> items = await _dataBaseConnection.query<ArchivedItem>((item) => mediaItem.getId() == item.mediaItemId);
    return items.isNotEmpty;
  }

  void setMediaItemArchived(Logic.MediaItem mediaItem) {
    ArchivedItem archivedItem = ArchivedItem.fromMediaItem(mediaItem.getPath(), mediaItem.getId());
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
        failedItemList.add(mediaItem.getPath() + "/" + mediaItem.getName());
        break;
      case UploadResult.Added:
        addedItems++;
        break;
      case UploadResult.AlreadyArchived:
        countSkippedImage();
        Logging.logInfo(sprintf("Skipping %s", [mediaItem.getPath()]));
        break;
    }
  }

  Future<UploadResult> uploadVideo(Logic.MediaItem video) async {
    String fileName = Uri.parse(video.getPath()).pathSegments.last;
    return await _serverAccess.uploadVideo(await video.readFileData(), fileName);
  }

  Future<UploadResult> uploadImage(Logic.MediaItem image) async {
    return await _serverAccess.uploadImage(await image.readFileData(), image.getName());
  }

  void reset() {
    totalItems = 0;
    processedItems = 0;
    addedItems = 0;
    skippedItems = 0;
    failedItems = 0;
    duplicateInPhone = 0;
    queue.clear();
    processedHashes.clear();
  }
}
