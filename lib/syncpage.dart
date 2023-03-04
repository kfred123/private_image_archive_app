import 'dart:async';

import 'package:flutter/material.dart';
import 'package:private_image_archive_app/db/database.dart';
import 'package:private_image_archive_app/logic/Permissions.dart';
import 'package:private_image_archive_app/logic/archiver.dart';
import 'package:private_image_archive_app/logic/server.dart';
import 'package:private_image_archive_app/logic/settings_provider.dart';
import 'package:uuid/uuid.dart';
import 'db/settings.dart';
import 'settings.dart';
import 'debugPage.dart';
import 'logic/media_provider.dart' as logic;
import 'sidenavigation.dart';
import 'logging.dart';


class SyncPage extends StatefulWidget {
  static const String RouteName = "/SyncPageWidget";

  SyncPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _SyncPageState createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  Archiver? _archiver;
  String _serverState = "unknown";
  Color _serverStateColor = Color.fromARGB(0, 0, 255, 0);
  Timer? _timer;

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
    if (await PermissionManager.requestPermissions()) {
      String baseUrl = await SettingsProvider.getServerUrl();
      DataBaseConnection dataBaseConnection = await DataBaseFactory.connect();
      _archiver = new Archiver(new ServerAccess(baseUrl), dataBaseConnection);
      logic.MediaProvider imageProvider = new logic.MediaProvider();
      Stream<logic.MediaItem> mediaItemStream = imageProvider.readAllMediaData();

      //for(logic.MediaItem image in mediaItems) {
      //  extensions.add(path.extension(image.getPath()));
      //}
      _archiver!.archiveMediaItems(mediaItemStream);
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        this.setState(() => {});
        if(_archiver!.isDoneArchiving()) {
          //timer.cancel();
        }
      });
    }
  }

  void _cancel() {
    _archiver!.cancel();
    _timer!.cancel();
  }

  String _getProgressPercentage() {
    String result = "";
    if(_archiver != null && _archiver!.totalItems != 0) {
      int percentage = (100 * _archiver!.processedItems / _archiver!.totalItems).round();
      result = "$percentage %";
    }
    return result;
  }

  void _openSettingsPage() async {
    await Navigator.pushNamed(
        context, ServerConnectionWidget.RouteName);
    _checkServerState();
  }

  void _openDebugPage() async {
    await Navigator.pushNamed(context, DebugWidget.RouteName);
  }

  _SyncPageState() {
    _checkServerState();
  }

  List<Text> _getFailedItems() {
    List<Text> result = List.empty(growable: true);
    if(_archiver != null && _archiver!.failedItemList != null) {
      for (String item in _archiver!.failedItemList) {
        Text element = new Text(item);
      }
    }
    return result;
  }

  String getIntOrEmptyString(int? number) {
    return number != null ? number.toString() : "";
  }

  @override
  Widget build(BuildContext context) {
    Logging.logInfo("start building SyncPage");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          ElevatedButton(
              child: Text("Settings"),
              onPressed: _openSettingsPage
          ),
          ElevatedButton(
              onPressed: _openDebugPage,
              child: Text("Debug"))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("server:"),
            Text(_serverState/*, style: TextStyle(color: _serverStateColor)*/),
            Text('skipped images:'),
            Text(getIntOrEmptyString(_archiver?.skippedItems)),
            Text('duplicate on phone:'),
            Text(getIntOrEmptyString(_archiver?.duplicateInPhone)),
            Text('failed uploads:'),
            Text(getIntOrEmptyString(_archiver?.failedItems)),
            Text('added images:'),
            Text(getIntOrEmptyString(_archiver?.addedItems)),
            Text('processed images:'),
            Text(getIntOrEmptyString(_archiver?.processedItems)),
            Text('total image count:'),
            Text(getIntOrEmptyString(_archiver?.totalItems)),
            //Text('currently processing:'),
            // Text(_archiver?.currentlyProcessing.toString()),
            Text('Progress:', textScaleFactor: 2.0),
            Text(_getProgressPercentage(), textScaleFactor: 2.0),
            //ListView(
            //  children: _getFailedItems()
            //)
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                // ToDo FileUpload for desktop apps
            },
              child: Icon(Icons.upload)
              )
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _start,
              tooltip: 'Run',
              heroTag: null,
              child: Icon(Icons.backup),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: _cancel,
              tooltip: 'Cancel',
              heroTag: null,
              child: Icon(Icons.cancel),
            ),
          )            ,
        ],
      ),
    );
  }
}