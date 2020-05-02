import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:private_image_archive_app/logic/archiver.dart';
import 'package:private_image_archive_app/logic/server.dart';
import 'package:private_image_archive_app/logic/settings_provider.dart';
import 'settings.dart';
import 'logic/image_provider.dart' as logic;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        ServerConnectionWidget.RouteName: (context) => ServerConnectionWidget()
      },
      title: 'Flutter Demo',
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

  void _start() async {
    List<PermissionGroup> requestPermissions = new List<PermissionGroup>();
    requestPermissions.add(PermissionGroup.photos);
    Map<PermissionGroup, PermissionStatus> permissions = await
                PermissionHandler().requestPermissions(requestPermissions);
    if (permissions[PermissionGroup.photos] == PermissionStatus.granted) {
      String baseUrl = await SettingsProvider.getServerUrl();
      _archiver = new Archiver(new ServerAccess(baseUrl));
      logic.ImageProvider imageProvider = new logic.ImageProvider();
      Stream<logic.Image> images = imageProvider.readImages();
      _archiver.archiveImages(images);
      /*images.listen((image) => {
        this.setState(() {})
      });*/
    }
}

@override
Widget build(BuildContext context) {
  // This method is rerun every time setState is called, for instance as done
  // by the _incrementCounter method above.
  //
  // The Flutter framework has been optimized to make rerunning build methods
  // fast, so that you can just rebuild anything that needs updating rather
  // than having to individually change instances of widgets.
  return Scaffold(
    appBar: AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Text(widget.title),
      actions: <Widget>[
        RaisedButton(
            child: Text("Settings"),
            onPressed: () =>
                Navigator.pushNamed(context, ServerConnectionWidget.RouteName)
        ),
      ],
    ),
    body: Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Invoke "debug painting" (press "p" in the console, choose the
        // "Toggle Debug Paint" action from the Flutter Inspector in Android
        // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
        // to see the wireframe for each widget.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('skipped images:'),
          Text(_archiver?.skippedImages.toString()),
          Text('added images:'),
          Text(_archiver?.addedImages.toString()),
          Text('processed images:'),
          Text(_archiver?.processedImages.toString()),
          Text('total image count:'),
          Text(_archiver?.totalImages.toString())
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _start,
      tooltip: 'Run',
      child: Icon(Icons.backup),
    ), // This trailing comma makes auto-formatting nicer for build methods.
  );
}}
