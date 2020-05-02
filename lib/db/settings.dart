import 'dbobject.dart';

class Settings extends DbObject {
  String _serverPath;

  Settings();

  @override
  List<DbColumn> getColumns() {
    return [
      new DbColumn("serverPath", DbColumn.TYPE_TEXT, () => _serverPath, (val) => _serverPath = val)
    ];
  }

  @override
  String getTableName() {
    return "Settings";
  }

  String getServerPath() {
    return _serverPath;
  }

  void setServerPath(String serverPath) {
    _serverPath = serverPath;
  }
}