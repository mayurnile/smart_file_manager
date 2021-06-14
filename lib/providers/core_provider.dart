import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_ex/path_provider_ex.dart';

import '../core/core.dart';

class CoreProvider extends GetxController {
  List<FileSystemEntity> availableStorage = [];
  List<FileSystemEntity> recentFiles = [];

  var totalSpace = 0;
  var freeSpace = 0;
  var totalSDSpace = 0;
  var freeSDSpace = 0;
  var usedSpace = 0;
  var usedSDSpace = 0;
  bool loading = true;
  List<dynamic> appData = [];

  //categorized sizes
  int totalAppSize = 0;
  int totalImageSize = 0;
  int totalVideoSize = 0;

  @override
  onInit() {
    super.onInit();

    checkSpace();
  }

  checkSpace() async {
    setLoading(true);
    recentFiles.clear();
    availableStorage.clear();
    List<FileSystemEntity> l = await getExternalStorageDirectories();
    availableStorage.addAll(l);
    update();
    MethodChannel platform =
        MethodChannel('dev.mayurnile.smartfilemanager/storage');
    var free = await platform.invokeMethod("getStorageFreeSpace");
    var total = await platform.invokeMethod("getStorageTotalSpace");
    Map<dynamic, dynamic> appData = await platform.invokeMethod("getApps");
    appData.forEach((key, value) {
      int data = value as int;
      totalAppSize += data;
    });
    getAllImagesSize();
    getAllVideosSize();
    getAndroidAppSize();
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

  getAllImagesSize() async {
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0].rootDir;
    int imagesBytes = 0;

    try {
      imagesBytes += await _fetchFiles(root + '/DCIM/Camera/');
      imagesBytes += await _fetchFiles(root + '/Download/');
      imagesBytes += await _fetchFiles(root + '/DCIM/');
      imagesBytes +=
          await _fetchFiles(root + '/WhatsApp/Media/WhatsApp Images/');
      imagesBytes +=
          await _fetchFiles(root + '/WhatsApp/Media/WhatsApp Images/Sent/');
      imagesBytes +=
          await _fetchFiles(root + '/WhatsApp/Media/WhatsApp Documents/');
      imagesBytes +=
          await _fetchFiles(root + '/WhatsApp/Media/WhatsApp Documents/Sent/');
      imagesBytes += await _fetchFiles(root + '/DCIM/Screenshots');
      imagesBytes += await _fetchFiles(root + '/Pictures/Screenshots');
      imagesBytes += await _fetchFiles(root + '/Pictures/AdobeLightroom');
    } catch (_) {}
    totalImageSize += imagesBytes;
    update();
  }

  getAndroidAppSize() async {
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0].rootDir;
    int totalSize = 0;
    var dir = Directory(root + '/Android/');
    try {
      if (dir.existsSync()) {
        dir
            .listSync(recursive: true, followLinks: false)
            .forEach((FileSystemEntity entity) {
          if (entity is File) {
            totalSize += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      print(e.toString());
    }
    totalAppSize += totalSize;
    update();
  }

  getAllVideosSize() async {
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0].rootDir;
    int videosBytes = 0;
    try {
      videosBytes += await _fetchVideoFiles(root + '/DCIM/Camera/');
      videosBytes += await _fetchVideoFiles(root + '/Download/');
      videosBytes += await _fetchVideoFiles(root + '/DCIM/');
      videosBytes +=
          await _fetchVideoFiles(root + '/WhatsApp/Media/WhatsApp Video/');
      videosBytes +=
          await _fetchVideoFiles(root + '/WhatsApp/Media/WhatsApp Video/Sent/');
      videosBytes +=
          await _fetchVideoFiles(root + '/WhatsApp/Media/WhatsApp Documents/');
      videosBytes += await _fetchVideoFiles(
          root + '/WhatsApp/Media/WhatsApp Documents/Sent/');
      videosBytes += await _fetchVideoFiles(root + '/DCIM/ScreenRecoder');
      videosBytes += await _fetchVideoFiles(root + '/Pictures/ScreenRecoder');
    } catch (_) {}
    totalVideoSize += videosBytes;
    update();
  }

  Future<int> _fetchFiles(String path) async {
    int totalBytes = 0;
    Directory myDir = Directory('$path');

    await myDir.list().forEach((element) {
      RegExp regExp = RegExp(
        "\.(jpe?g|png)",
        caseSensitive: false,
      );
      // Only add in List if path is an image
      if (regExp.hasMatch('$element')) {
        totalBytes += File.fromUri(Uri.parse(element.path)).lengthSync();
      }
    });
    return totalBytes;
  }

  Future<int> _fetchVideoFiles(String path) async {
    int totalBytes = 0;
    Directory myDir = Directory('$path');

    await myDir.list().forEach((element) {
      RegExp regExp = RegExp(
        "\.(mp4|mkv)",
        caseSensitive: false,
      );
      // Only add in List if path is an image
      if (regExp.hasMatch('$element')) {
        totalBytes += File.fromUri(Uri.parse(element.path)).lengthSync();
      }
    });
    return totalBytes;
  }

  getRecentFiles() async {
    List<FileSystemEntity> l =
        await FileUtils.getRecentFiles(showHidden: false);
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
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  calculatePercent(int usedSpace, int totalSpace) {
    return double.parse((usedSpace / totalSpace * 100).toStringAsFixed(0)) /
        100;
  }
}
