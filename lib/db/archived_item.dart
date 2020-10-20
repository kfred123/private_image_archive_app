import 'dbobject.dart';

class ArchivedItem extends DbObject {
  static final String COL_MEDIA_ITEM_PATH = "mediaItemPath";
  static final String COL_ARCHIVED_DATE = "archivedDate";
  String _mediaItemPath = "";
  DateTime _archivedDate = null;

  @override
  List<DbColumn> getColumns() {
    return [
      new DbColumn(COL_MEDIA_ITEM_PATH, DbColumn.TYPE_TEXT, () => _mediaItemPath, (value) => _mediaItemPath = value),
      new DbColumn(COL_ARCHIVED_DATE, DbColumn.TYPE_TEXT, () => _archivedDate.toIso8601String(), (value) => _archivedDate = DateTime.tryParse(value))
    ];
  }

  @override
  String getTableName() {
    return "ArchivedItem";
  }

  DateTime get archivedDate => _archivedDate;

  set archivedDate(DateTime value) {
    _archivedDate = value;
  }

  String get mediaItemPath => _mediaItemPath;

  set mediaItemPath(String value) {
    _mediaItemPath = value;
  }
}