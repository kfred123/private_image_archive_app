import 'package:hive_flutter/adapters.dart';

import 'HiveTypes.dart';
import 'dbobject.dart';

part 'archived_item.g.dart';

@HiveType(typeId: HiveTypes.ARCHIVED_ITEM)
class ArchivedItem extends DbObject {
  @HiveField(1)
  String _mediaItemPath = "";
  @HiveField(2)
  String _mediaItemId = "";
  @HiveField(3)
  DateTime? _archivedDate;

  ArchivedItem();

  ArchivedItem.fromMediaItem(String path, String id) {
    _mediaItemPath = path;
    _mediaItemId = id;
    _archivedDate = DateTime.now();
  }

  DateTime? get archivedDate => _archivedDate;

  set archivedDate(DateTime? value) {
    _archivedDate = value;
  }

  String get mediaItemPath => _mediaItemPath;

  set mediaItemPath(String value) {
    _mediaItemPath = value;
  }

  String get mediaItemId => _mediaItemId;
}