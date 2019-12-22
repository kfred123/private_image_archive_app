import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServerConnectionWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ServerConnectionState();
  }
}

class ServerConnectionState extends State {
  String _server;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text("Server"),
                  ],
                ),
                Column(
                  children: <Widget>[
                    TextField(onSubmitted: (value) => _server = value)
                  ],
                )
              ],
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  child: Text("Save"),
                  onPressed: () => null,
                )
              ],
            ),
          ],
        )
    );
  }

}