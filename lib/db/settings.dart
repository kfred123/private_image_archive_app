import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';
import 'HiveTypes.dart';

import 'dbobject.dart';

part 'settings.g.dart';

@HiveType(typeId: HiveTypes.SETTINGS)
class Settings extends DbObject {
  @HiveField(1)
  String _serverPath = "";
  @HiveField(2)
  String _phoneId = "";

  Settings();

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