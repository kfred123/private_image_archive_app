import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:private_image_archive_app/db/archived_item.dart';
import 'package:private_image_archive_app/db/database.dart';
import 'package:private_image_archive_app/logic/settings_provider.dart';
import 'package:private_image_archive_app/db/settings.dart';

class ServerConnectionWidget extends StatefulWidget {
  static const String RouteName = "/ServerConnectionWidget";

  @override
  State<StatefulWidget> createState() {
    return ServerConnectionState();
  }
}

class ServerConnectionState extends State {
  TextEditingController _serverTextController = TextEditingController();
  late Settings _settings;
  void init() async {
    _settings = await SettingsProvider.getSettings();
    _serverTextController.text = _settings.getServerPath();
  }

  void save() {
    _settings.setServerPath(_serverTextController.text);
    SettingsProvider.saveSettings(_settings);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Scaffold(
      body:
          Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text("Server"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            TextField(
                              controller: _serverTextController,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      ElevatedButton(
                          child: Text("Save"),
                          onPressed: () => save()
                      )
                    ],
                  ),
                ],
              ),
          )
    );
  }

}