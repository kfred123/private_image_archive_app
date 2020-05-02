import 'package:private_image_archive_app/db/database.dart';
import 'package:private_image_archive_app/db/dbobject.dart';
import 'package:private_image_archive_app/db/settings.dart';
import 'package:private_image_archive_app/settings.dart';
import 'package:private_image_archive_app/logging.dart';

class SettingsProvider {
  static Future<Settings> getSettings() async {
    DataBaseConnection dbConnection = await DataBaseFactory.connect();
    List settings = await dbConnection.query(() => new Settings());
    if(settings.length > 1) {
      Logging.logError("found too many Settings-objects, using first");
    }

    Settings result;
    if(settings.length > 0) {
      result = settings[0];
    } else {
      result = new Settings();
    }
    return result;
  }

  static Future<String> getServerUrl() async {
    Settings settings = await getSettings();
    return settings.getServerPath();
  }

  static void saveSettings(Settings settings) async {
    DataBaseConnection dbConnection = await DataBaseFactory.connect();
    dbConnection.updateOrInsert(settings);
  }
}