import 'package:uuid/uuid.dart';

import 'dbobject.dart';

class Settings extends DbObject {
  String _serverPath = "";
  String _phoneId = "";

  Settings();

  @override
  List<DbColumn> getColumns() {
    return [
      new DbColumn("serverPath", DbColumn.TYPE_TEXT, () => _serverPath, (val) => _serverPath = val),
      new DbColumn("phoneId", DbColumn.TYPE_TEXT, () => _phoneId, (val) => _phoneId = val)
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

  String get phoneId => _phoneId;

  set phoneId(String value) {
    _phoneId = value;
  }
}