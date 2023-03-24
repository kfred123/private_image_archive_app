// @dart=2.9
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:private_image_archive_app/db/database.dart';
import 'package:private_image_archive_app/logic/Permissions.dart';
import 'package:private_image_archive_app/logic/archiver.dart';
import 'package:private_image_archive_app/logic/server.dart';
import 'package:private_image_archive_app/logic/settings_provider.dart';
import 'package:private_image_archive_app/syncpage.dart';
import 'package:uuid/uuid.dart';
import 'db/settings.dart';
import 'settings.dart';
import 'debugPage.dart';
import 'logic/media_provider.dart' as logic;
import 'sidenavigation.dart';
import 'logging.dart';

void main() {
  try {
    runApp(MyApp());
  } catch(e) {
    Logging.logInfo(e.toString());
  }
}

void initPhoneId() async {
  Logging.logInfo("Start initPhoneId");
  Settings settings = await SettingsProvider.getSettings();
  if(settings.phoneId.isEmpty) {
    settings.phoneId = new Uuid().v4();
    SettingsProvider.saveSettings(settings);
  }
  Logging.logInfo("End initPhoneId");
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initPhoneId();
    Logging.logInfo("start build MaterialApp");
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        SyncPage.RouteName: (context) => SyncPage(title: "SyncPage"),
        ServerConnectionWidget.RouteName: (context) => ServerConnectionWidget(),
        DebugWidget.RouteName: (context) => DebugWidget()
      },
      title: 'Private Image Archive',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: SideNavigation()
    );
  }
}