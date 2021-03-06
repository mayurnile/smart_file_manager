import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/core.dart';
import '../screens/main_screen/main_screen.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  startTimeout() {
    return Timer(Duration(seconds: 2), handleTimeout);
  }

  void handleTimeout() {
    changeScreen();
  }

  changeScreen() async {
    PermissionStatus status = await Permission.storage.status;
    if (status.isGranted) {
      requestPermission();
    } else {
      Navigate.pushPageReplacement(context, MainScreen());
    }
  }

  requestPermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      Navigate.pushPageReplacement(context, MainScreen());
    } else {
      Dialogs.showToast('Please Grant Storage Permissions');
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    startTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Feather.folder,
              color: Theme.of(context).accentColor,
              size: 70.0,
            ),
            SizedBox(height: 20.0),
            Text(
              "${AppStrings.appName}",
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
