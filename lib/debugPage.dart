import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:private_image_archive_app/db/database.dart';
import 'package:private_image_archive_app/logic/server.dart';
import 'package:private_image_archive_app/logic/settings_provider.dart';
import 'package:private_image_archive_app/uiutils.dart';
import 'db/database.dart';
import 'db/archived_item.dart';

class DebugWidget extends StatelessWidget {
  static const String RouteName = "/DebugWidget";
  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    // TODO: implement build
    return ListView(
      children: [
        Text("-DEBUG-"),
        TextButton(onPressed: _flushAppAndServer, child: Text("Flush App and Server")),
        TextButton(
          child: Text("Clear ArchivedEntries"),
          onPressed: () => clearEntries(),
        ),
        TextButton(
          child: Text("Delete Database"),
          onPressed: () => deleteDatabase(),
        )
      ],
    );
  }

  void _flushAppAndServer() async {
    String serverUrl = await SettingsProvider.getServerUrl();
    var serverAccess = ServerAccess(serverUrl);
    try {
      await serverAccess.deleteAllImagesAndVideos();
      await DataBaseFactory.delete();
      showDebugDialog(_context, "DONE");
    } catch(e) {
      showDebugDialog(_context, e.toString());
    }
  }

  void clearEntries() async {
    DataBaseConnection connection = await DataBaseFactory.connect();
    connection.clearTable(ArchivedItem().getTableName());
  }

  void deleteDatabase() async {
    DataBaseFactory.delete();
  }
}