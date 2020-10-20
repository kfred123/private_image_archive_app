import 'dart:async';
import 'package:private_image_archive_app/db/archived_item.dart';
import 'package:private_image_archive_app/db/dbobject.dart';
import 'package:private_image_archive_app/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'settings.dart';

class DataBaseFactory {
  static Future<DataBaseConnection> connect() async {
    String dbPath = await getDatabasesPath();
    Database db = await openDatabase(join(dbPath, "privateimagearchive.db"),
        onCreate: DataBaseFactory.onCreate, version: 1);
    return DataBaseConnection(db);
  }

  static FutureOr onCreate(Database db, int version) {
    createTable(db, Settings());
    createTable(db, ArchivedItem());
  }

  static void createTable(Database db, DbObject templateObj) {
    String create = "CREATE TABLE ";
    create += templateObj.getTableName();
    create += "(" + DbObject.COL_ID + " INTEGER PRIMARY KEY";
    for (DbColumn col in templateObj.getColumns()) {
      create += ",";
      create += col.name;
      create += " ";
      create += col.type;
    }
    create += ")";
    db.execute(create);
  }
}

class DatabaseFactory {}

class DataBaseConnection {
  Database _database;

  DataBaseConnection(this._database);

  Future<List<T>> query<T extends DbObject>(
      T Function() constructor,
      {String where,
      List<dynamic> whereArgs}) async {
    DbObject dummyObject = constructor();
    List<T> result = new List();
    List<Map> queryResult = await _database.query(dummyObject.getTableName(),
        where: where, whereArgs: whereArgs);
    if (queryResult.isNotEmpty) {
      for (var row in queryResult) {
        T obj = constructor();
        obj.id = row[DbObject.COL_ID];
        result.add(obj);
        for (DbColumn dbColumn in obj.getColumns()) {
          if (row.containsKey(dbColumn.name)) {
            dbColumn.setValueFunc(row[dbColumn.name]);
          } else {
            Logging.logError(
                "databaserow does not contain a value for column ${dbColumn.name}, id=${obj.id}");
          }
        }
      }
    }
    return result;
  }

  void updateOrInsert(DbObject dbObject) async {
    // _database.query(dbObject.getTableName(), where: "${DbObject.COL_ID} = ?", whereArgs: List.of({dbObject.id}));

    Map<String, dynamic> values = new Map();
    for (DbColumn dbColumn in dbObject.getColumns()) {
      values.putIfAbsent(dbColumn.name, dbColumn.getValueFunc);
    }

    if (dbObject.id == 0) {
      int result = await _database.insert(dbObject.getTableName(), values,
          conflictAlgorithm: ConflictAlgorithm.replace);
      dbObject.id = result;
    } else {
      _database.update(dbObject.getTableName(), values,
          where: "${DbObject.COL_ID} = ?", whereArgs: List.of({dbObject.id}));
    }
  }

  void clearTable(String table) {
    _database.execute("DELETE FROM $table");
  }
}
