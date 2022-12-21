import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:private_image_archive_app/main.dart';

class SideNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
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
    );
  }
  
}