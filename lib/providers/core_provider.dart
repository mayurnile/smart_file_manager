import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../core/core.dart';

class CoreProvider extends GetxController {
  List<FileSystemEntity> availableStorage = List();
  List<FileSystemEntity> recentFiles = List();

  int totalSpace = 0;
  int freeSpace = 0;
  int totalSDSpace = 0;
  int freeSDSpace = 0;
  int usedSpace = 0;
  int usedSDSpace = 0;
  bool loading = true;
  List<dynamic> appData = [];

  checkSpace() async {
    setLoading(true);
    recentFiles.clear();
    availableStorage.clear();
    List<FileSystemEntity> l = await getExternalStorageDirectories();
    availableStorage.addAll(l);
    update();
    MethodChannel platform = MethodChannel('dev.jideguru.filex/storage');
    var free = await platform.invokeMethod("getStorageFreeSpace");
    var total = await platform.invokeMethod("getStorageTotalSpace");
    Map<dynamic, dynamic> appData = await platform.invokeMethod("getApps");
    appData.forEach((key, value) {
      int data = value as int;
      print('$key: ${formatBytes(data, 2)}');
    });
    setFreeSpace(free);
    setTotalSpace(total);
    setUsedSpace(total - free);
    if (l.length > 1) {
      var freeSD = await platform.invokeMethod("getExternalStorageFreeSpace");
      var totalSD = await platform.invokeMethod("getExternalStorageTotalSpace");
      setFreeSDSpace(freeSD);
      setTotalSDSpace(totalSD);
      setUsedSDSpace(totalSD - freeSD);
    }
    getRecentFiles();
  }

  getRecentFiles() async {
    List<FileSystemEntity> l = await FileUtils.getRecentFiles(showHidden: false);
    recentFiles.addAll(l);
    setLoading(false);
  }

  void setFreeSpace(value) {
    freeSpace = value;
    update();
  }

  void setTotalSpace(value) {
    totalSpace = value;
    update();
  }

  void setUsedSpace(value) {
    usedSpace = value;
    update();
  }

  void setFreeSDSpace(value) {
    freeSDSpace = value;
    update();
  }

  void setTotalSDSpace(value) {
    totalSDSpace = value;
    update();
  }

  void setUsedSDSpace(value) {
    usedSDSpace = value;
    update();
  }

  void setLoading(value) {
    loading = value;
    update();
  }

  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }
}
