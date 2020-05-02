abstract class DbObject {
  static final String COL_ID = "id";

  int _id = 0;

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  List<DbColumn> getColumns();
  String getTableName();
}

class DbColumn {
  static const String TYPE_TEXT = "Text";
  static const String TYPE_INT = "Integer";

  final String name;
  final String type;
  final Object Function() getValueFunc;
  final Function(Object) setValueFunc;
  DbColumn(this.name, this.type, this.getValueFunc, this.setValueFunc);
}
