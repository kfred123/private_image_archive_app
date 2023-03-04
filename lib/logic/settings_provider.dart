import 'package:private_image_archive_app/db/database.dart';
import 'package:private_image_archive_app/db/dbobject.dart';
import 'package:private_image_archive_app/db/settings.dart';
import 'package:private_image_archive_app/settings.dart';
import 'package:private_image_archive_app/logging.dart';

class SettingsProvider {
  static Future<Settings> getSettings() async {
    DataBaseConnection dbConnection = await DataBaseFactory.connect();
    Settings? settings = await dbConnection.getSingleItem<Settings>();
    if(settings == null) {
      settings = new Settings();
    }
    return settings;
  }

  static Future<String> getServerUrl() async {
    Settings settings = await getSettings();
    return settings.getServerPath();
  }

  static void saveSettings(Settings settings) async {
    Logging.logInfo("Start saveSetting");
    DataBaseConnection dbConnection = await DataBaseFactory.connect();
    dbConnection.updateOrInsert(settings);
    Logging.logInfo("End saveSettings");
  }
}