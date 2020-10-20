import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:private_image_archive_app/db/database.dart';
import 'package:private_image_archive_app/logic/archiver.dart';
import 'package:private_image_archive_app/logic/server.dart';
import 'package:private_image_archive_app/logic/settings_provider.dart';
import 'package:uuid/uuid.dart';
import 'db/settings.dart';
import 'settings.dart';
import 'logic/media_provider.dart' as logic;

void main() {
  runApp(MyApp());
}

void initPhoneId() async {
  Settings settings = await SettingsProvider.getSettings();
  if(settings.phoneId.isEmpty) {
    settings.phoneId = new Uuid().v4();
    SettingsProvider.saveSettings(settings);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initPhoneId();
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        ServerConnectionWidget.RouteName: (context) => ServerConnectionWidget()
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Archiver _archiver;
  String _serverState = "unknown";
  Color _serverStateColor = Color.fromARGB(0, 0, 255, 0);

  void _checkServerState() async {
    String serverUrl = await SettingsProvider.getServerUrl();
    if(serverUrl.isNotEmpty) {
      setState(() {
        _serverState = "checking...";
      });
      ServerAccess serverAccess = new ServerAccess(serverUrl);
      bool isAvailable = await serverAccess.isServerAvailable();
      setState(() {
        if(isAvailable) {
          _serverState = "available";
          _serverStateColor = Color.fromARGB(0, 255, 255, 0);
        } else {
          _serverState = "unavailable";
          _serverStateColor = Color.fromARGB(0, 255, 0, 0);
        }
      });
    }
    /*Timer(Duration(seconds: 10), () {
      _checkServerState();
    });*/
  }

  void _start() async {
    List<PermissionGroup> requestPermissions = new List<PermissionGroup>();
    requestPermissions.add(PermissionGroup.photos);
    requestPermissions.add(PermissionGroup.storage);
    requestPermissions.add(PermissionGroup.mediaLibrary);
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions(requestPermissions);
    if (permissions[PermissionGroup.photos] == PermissionStatus.granted) {
      String baseUrl = await SettingsProvider.getServerUrl();
      DataBaseConnection dataBaseConnection = await DataBaseFactory.connect();
      _archiver = new Archiver(new ServerAccess(baseUrl), dataBaseConnection);
      logic.MediaProvider imageProvider = new logic.MediaProvider();
      List<logic.MediaItem> mediaItems = await imageProvider.readAllMediaData();
      Set<String> extensions = new Set();
      for(logic.MediaItem image in mediaItems) {
        extensions.add(path.extension(image.getPath()));
      }
      // ToDo Limitierung auf 100 rausnehmen
      //_archiver.archiveMediaItems(mediaItems.take(100));
      _archiver.archiveMediaItems(mediaItems);
      Timer timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        this.setState(() => {});
        if(_archiver.isDoneArchiving()) {
          timer.cancel();
        }
      });
    }
  }

  String _getProgressPercentage() {
    String result = "";
    if(_archiver != null) {
      int percentage = (100 * _archiver.processedItems / _archiver.totalItems).round();
      result = "$percentage %";
    }
    return result;
  }

  void _openSettingsPage() async {
    await Navigator.pushNamed(
        context, ServerConnectionWidget.RouteName);
    _checkServerState();
  }

  _MyHomePageState() {
    _checkServerState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          RaisedButton(
              child: Text("Settings"),
              onPressed: _openSettingsPage
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("server:"),
            Text(_serverState/*, style: TextStyle(color: _serverStateColor)*/),
            Text('skipped images:'),
            Text(_archiver?.skippedItems.toString()),
            Text('duplicate on phone:'),
            Text(_archiver?.duplicateInPhone.toString()),
            Text('failed uploads:'),
            Text(_archiver?.failedItems.toString()),
            Text('added images:'),
            Text(_archiver?.addedItems.toString()),
            Text('processed images:'),
            Text(_archiver?.processedItems.toString()),
            Text('total image count:'),
            Text(_archiver?.totalItems.toString()),
            Text('currently processing:'),
            Text(_archiver?.currentlyProcessing.toString()),
            Text('Progress:', textScaleFactor: 2.0),
            Text(_getProgressPercentage(), textScaleFactor: 2.0)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _start,
        tooltip: 'Run',
        child: Icon(Icons.backup),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
