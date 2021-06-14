import 'dart:io';
import 'dart:typed_data';

// import 'package:duplicatespart2/screens/viewphotos.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smart_file_manager/core/core.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../core/hashing/difference_hash.dart';

class NearDuplicateFinder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NearDuplicateFinderState();
  }
}

class _NearDuplicateFinderState extends State<NearDuplicateFinder> {
  DuplicateCountProvider controller;

  Map<String, Uint8List> dupFiles = {};
  bool noFiles = false;

  int mid = 0;

  var isSelected = false;
  bool selected = false;
  var mycolor = Colors.white;
  var myDupPath = [];
  bool deleted = false;
  @override
  void initState() {
    controller = Get.put(DuplicateCountProvider());
    controller.duplicateFilesList = [];
    getFiles();
    super.initState();
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Near Duplicate Images",
          style: TextStyle(color: SmartFileManagerTheme.PRIMARY_COLOR),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: SmartFileManagerTheme.PRIMARY_COLOR),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete_forever,
                  color: SmartFileManagerTheme.PRIMARY_COLOR),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      "Are you sure?",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    content: Text(
                      "Click YES if you want to delete all selected images",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          for (int i = 0; i < myDupPath.length; i++) {
                            deleteFile(File(myDupPath[i]));
                          }
                          // Navigator.of(context)
                          //     .pushReplacementNamed(Routes.TABS);
                        },
                        child: Text(
                          "YES",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                      FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Text(
                            "No",
                            style: Theme.of(context).textTheme.headline3,
                          ))
                    ],
                  ),
                );
              }),
        ],
      ),
      body: GetBuilder<DuplicateCountProvider>(
        init: DuplicateCountProvider(),
        builder: (provider) {
          return deleted
              ? Center(child: Text("No File Found..."))
              : provider.duplicateFilesList.isEmpty
                  ? Center(child: Text("Searching Files.."))
                  : Container(
                      margin: EdgeInsets.all(8.0),
                      child: StaggeredGridView.countBuilder(
                        itemCount: provider.result.length,
                        crossAxisCount: 4,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          String imgPath =
                              "https://ia-discourse.s3-us-west-1.amazonaws.com/original/2X/9/97d457372f6c14182b686ecfdf5d4067df5e9373.png";
                          if (provider.result[index].path != null) {
                            imgPath = provider.result[index].path;
                            myDupPath.add(imgPath);
                          }
                          return Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Material(
                                elevation: 8.0,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                shadowColor: Colors.black,
                                child: InkWell(
                                  onTap: () {
                                    // Navigator.push(
                                    //     context,
                                    //     new MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             new ViewPhotos(imgPath)));
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      Image.file(
                                        File(imgPath.toString()),
                                        height: mediaQuery.size.height * 0.5,
                                        width: mediaQuery.size.width * 0.5,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        staggeredTileBuilder: (i) =>
                            StaggeredTile.count(2, i.isEven ? 2 : 3),
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                    );
        },
      ),
    );
  }

  Future<void> getFiles() async {
    //asyn function to get list of files
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0].rootDir;
    //storageInfo[1] for SD card, geting the root directory

    try {
      await _fetchFiles(root + '/DCIM/Camera/');
    } catch (_) {}

    try {
      await _fetchFiles(root + '/Download/');
    } catch (_) {}

    try {
      await _fetchFiles(root + '/DCIM/');
    } catch (_) {}

    DateTime todaysDate = DateTime.now();
    DateTime duration = todaysDate.subtract(Duration(days: 5));

    for (int i = 0; i < controller.files.length; i++) {
      DateTime lastModifiedTime = await controller.files[i].lastModified();
      if (lastModifiedTime.isAfter(duration) &&
          lastModifiedTime.isBefore(todaysDate)) {
        final bytes = await controller.files[i].readAsBytes();
        controller.shortListedFiles.add(
          MyFileModel(
            path: controller.files[i].path,
            name: controller.files[i].path.split("/").last,
            bytes: bytes,
            modifiedTime: lastModifiedTime,
          ),
        );
      }
    }

    ///printing length of shortlisted images
    print(controller.shortListedFiles.length);

    controller.shortListedFiles
        .sort((a, b) => a.modifiedTime.isAfter(b.modifiedTime) ? 0 : 1);

    // for (int i = 0; i < controller.shortListedFiles.length; i++) {
    //   controller.addDupInList(controller.shortListedFiles[i]);
    // }

    for (int i = 0; i < controller.shortListedFiles.length; i++) {
      for (int j = i + 1; j < controller.shortListedFiles.length; j++) {
        try {
          int difference = DifferenceHash().compare(
            imageLib.decodeImage(controller.shortListedFiles[i].bytes),
            imageLib.decodeImage(controller.shortListedFiles[j].bytes),
            i,
            j,
          );
          print('$i $j $difference ');
          if (difference == 0) {
            controller.addDupInList(controller.shortListedFiles[i]);
          } else if (difference <= 6 && difference >= 1) {
            controller.addDupInList(controller.shortListedFiles[i]);
          }
        } catch (e) {
          print(e);
        }
      }
    }

    // ReceivePort receivePort = ReceivePort();
    // ReceivePort receivePort2 = ReceivePort();

    // Isolate.spawn(
    //   findDuplicates,
    //   DuplicateFile(
    //     name: 'Thread 1',
    //     isEven: false,
    //     files: controller.shortListedFiles,
    //     sendPort: receivePort.sendPort,
    //   ),
    // );

    // await Isolate.spawn(
    //   findDuplicates,
    //   DuplicateFile(
    //     name: 'Thread 2',
    //     isEven: true,
    //     files: controller.shortListedFiles,
    //     sendPort: receivePort2.sendPort,
    //   ),
    // );

    // receivePort.listen((data) {
    //   controller.exactDuplicateCount += (data['exactCount'] as num).toInt();
    //   controller.nearDuplicateCount += (data['nearCount'] as num).toInt();
    //   controller.duplicateFilesList.addAll(data['dupFiles']);
    // });
    // receivePort2.listen((data) {
    //   controller.exactDuplicateCount += (data['exactCount'] as num).toInt();
    //   controller.nearDuplicateCount += (data['nearCount'] as num).toInt();
    //   controller.duplicateFilesList.addAll(data['dupFiles']);

    //   controller.refreshScreen();
    //   print('Exact Count : ${controller.exactDuplicateCount}');
    //   print('Near Count : ${controller.nearDuplicateCount}');
    // });

    controller.refreshScreen();
    // print('Exact Count : ${controller.exactDuplicateCount}');
    // print('Near Count : ${controller.nearDuplicateCount}');
    print('Count : ${controller.duplicateFilesList.length}');
    if (controller.result.isEmpty) {
      noFiles = true;
    }

    setState(() {}); //update the UI
  }

  _fetchFiles(String path) async {
    Directory myDir = Directory('$path');
    List<dynamic> listImage = List<dynamic>();
    await myDir.list().forEach((element) {
      RegExp regExp = RegExp(
        "\.(jpe?g|png)",
        caseSensitive: false,
      );
      // Only add in List if path is an image
      if (regExp.hasMatch('$element')) {
        listImage.add(element);
        controller.files.add(element);
      }
      setState(() {
        // listImagePath = listImage;
      });
    });
  }
}

//isolates
findDuplicates(DuplicateFile data) {
  int exactCount = 0;
  int nearCount = 0;
  List<MyFileModel> dupFiles = [];
  int startIndex = data.isEven ? 0 : 1;
  for (int i = 0; i < data.files.length - 1; i++) {
    for (int j = startIndex; j < data.files.length - 2; j += 2) {
      if (i != j)
        try {
          int difference = DifferenceHash().compare(
            imageLib.decodeImage(data.files[i].bytes),
            imageLib.decodeImage(data.files[j].bytes),
            i,
            j,
          );
          print('${data.name} $i $j $difference ');
          if (difference <= 4 && difference >= 0) {
            exactCount++;
            // dupFiles.add(data.files[j]);
          } else if (difference <= 15 && difference >= 4) {
            nearCount++;
            dupFiles.add(data.files[j]);
          }
        } catch (e) {
          print(e);
        }
    }
  }
  Map<String, dynamic> calculatedData = {
    'exactCount': exactCount,
    'nearCount': nearCount,
    'dupFiles': dupFiles,
  };
  data.sendPort.send(calculatedData);
}
