import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'core/core.dart';
import 'providers/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SmartFileManager());
}

class SmartFileManager extends StatelessWidget {
  final AppProvider appProvider = Get.put(AppProvider());
  final CategoryProvider categoryProvider = Get.put(CategoryProvider());
  final CoreProvider coreProvider = Get.put(CoreProvider());
  final DuplicateCountProvider duplicateCountProvider =
      Get.put(DuplicateCountProvider());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart File Manager',
      onGenerateRoute: generateRoute,
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService().navigatorKey,
      theme: SmartFileManagerTheme.smartFileManagerThemeData,
    );
  }
}
