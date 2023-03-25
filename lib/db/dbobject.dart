import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

abstract class DbObject {
  String id = Uuid().v4();
}
