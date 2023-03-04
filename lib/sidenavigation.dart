import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:private_image_archive_app/logging.dart';
import 'package:private_image_archive_app/main.dart';

import 'syncpage.dart';

class SideNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logging.logInfo("SideNavigation start build");
    return Scaffold(
      appBar: AppBar(
        title: Text("Private Imagearchive"),
      ),
      drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                title: Text("Search"),
                onTap: () => {

                },
              ),
              ListTile(
                title: Text("Sync"),
                onTap: () => {
                  Navigator.pushNamed(context, SyncPage.RouteName)
                },
              )
            ],
          )
      ),
    );
  }
}