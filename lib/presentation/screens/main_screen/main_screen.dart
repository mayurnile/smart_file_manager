import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../../screens/browse/browse.dart';
import '../../screens/share.dart';
import '../../screens/settings.dart';
import '../../../core/core.dart';
import '../../../providers/providers.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Dialogs.showExitDialog(context),
      child: Scaffold(
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            Browse(),
            Share(),
            Settings(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).primaryColor,
          selectedItemColor: Theme.of(context).accentColor,
          unselectedItemColor: Theme.of(context).textTheme.headline1.color,
          elevation: 4.0,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Feather.folder),
              label: "Browse",
            ),
            BottomNavigationBarItem(
              icon: Icon(Feather.share_2),
              label: "FTP",
            ),
            BottomNavigationBarItem(
              icon: Icon(Feather.settings),
              label: "Settings",
            ),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final CoreProvider _coreProvider = Get.find();
      _coreProvider.checkSpace();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }
}
