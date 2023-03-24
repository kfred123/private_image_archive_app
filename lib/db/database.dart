import 'dart:async';
import 'dart:io';
import 'package:private_image_archive_app/db/archived_item.dart';
import 'package:private_image_archive_app/db/dbobject.dart';
import 'package:private_image_archive_app/logging.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:path/path.dart' as path;
import 'settings.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataBaseFactory {
  static bool initialized = false;
  static initialize() async {
    if(!initialized) {
      await Hive.initFlutter("privateImageArchive");
      Hive.registerAdapter(SettingsAdapter());
      Hive.registerAdapter(ArchivedItemAdapter());
      initialized = true;
      var conection = await connect();

      // ToDo in windows app the db is always empty after starting it new
      var items = await conection.query<ArchivedItem>((p0) => true);
      var list = items.toList();
      int x = 0;
    }
  }

  static Future<DataBaseConnection> connect() async {
    await initialize();
    return new DataBaseConnection();
  }

  static Future<File> getDbPath() async {
    final dbPath = await pathProvider.getApplicationDocumentsDirectory();
    return File(path.join(dbPath.path, "privateimagearchive.db"));

  }

  static delete() async {
    Hive.deleteFromDisk();
  }
}

class DatabaseFactory {}

class DataBaseConnection {

  Future<T?> getSingleItem<T extends DbObject>() async {
    Iterable<T> all = await getAll<T>();
    if(all.length > 1) {
      Logging.logError("Found too many items of type $T: ${all.length}");
    }
    return all.length > 0 ? all.first : null;
  }

  Future<Iterable<T>> getAll<T extends DbObject>() async {
    return query((p0) => true);
  }

  Future<Iterable<T>> query<T extends DbObject>(
      bool Function(T) filter) async {
    Box<T> box = await Hive.openBox(T.toString());
    return box.values.where(filter);
  }

  void updateOrInsert<T extends DbObject>(T dbObject) async {
    Box<T> box = await Hive.openBox(T.toString());
    box.put(dbObject.id.toString(), dbObject);
  }

  void clearTable<T extends DbObject>() async {
    Box<T> box = await Hive.openBox(T.toString());
    box.clear();
  }
}