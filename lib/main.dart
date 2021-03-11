import 'package:get/get.dart';
import 'package:flutter/material.dart';

import './core/core.dart';

void main() {
  runApp(SmartFileManager());
}

class SmartFileManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart File Manager',
      onGenerateRoute: generateRoute,
      navigatorKey: NavigationService().navigatorKey,
      theme: SmartFileManagerTheme.smartFileManagerThemeData,
    );
  }
}