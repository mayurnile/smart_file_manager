import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../screens/about.dart';
import '../../core/core.dart';
import '../../providers/providers.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final CategoryProvider _categoryProvider = Get.find();
  final AppProvider _appProvider = Get.find();

  @override
  void initState() {
    super.initState();
    check();
  }

  int sdkVersion = 0;

  check() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      sdkVersion = androidInfo.version.sdkInt;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.all(0),
            secondary: Icon(
              Feather.eye_off,
            ),
            title: Text(
              "See hidden files",
            ),
            value: _categoryProvider.showHidden,
            onChanged: (value) {
              _categoryProvider.setHidden(value);
            },
            activeColor: Theme.of(context).accentColor,
          ),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          MediaQuery.of(context).platformBrightness !=
                  ThemeConfig.darkTheme.brightness
              ? SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.all(0),
                  secondary: Icon(
                    Feather.moon,
                  ),
                  title: Text("Dark mode"),
                  value: _appProvider.theme == ThemeConfig.lightTheme
                      ? false
                      : true,
                  onChanged: (v) {
                    if (v) {
                      _appProvider.setTheme(ThemeConfig.darkTheme, "dark");
                    } else {
                      _appProvider.setTheme(ThemeConfig.lightTheme, "light");
                    }
                  },
                  activeColor: Theme.of(context).accentColor,
                )
              : SizedBox(),
          MediaQuery.of(context).platformBrightness !=
                  ThemeConfig.darkTheme.brightness
              ? Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                )
              : SizedBox(),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            onTap: () => showLicensePage(context: context),
            leading: Icon(Feather.file_text),
            title: Text("Open source licences"),
          ),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            onTap: () => Navigate.pushPage(context, About()),
            leading: Icon(Feather.info),
            title: Text("About"),
          ),
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
        ],
      ),
    );
  }
}
