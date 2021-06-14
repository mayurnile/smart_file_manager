import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/widgets.dart';

final Directory _photoDir =
    new Directory('/storage/emulated/0/WhatsApp/Media/WhatsApp Images');

List<String> memes = [];
List<String> imageList;

int count = 0;
var imageListLength = _photoDir
    .listSync()
    .map((item) => item.path)
    .where((item) => item.endsWith(".jpg"))
    .toList(growable: false)
    .length;
var list = new List.filled(imageListLength, true, growable: true);
bool selected = false;

class MemeFinder extends StatefulWidget {
  // This widget is the root of your application.
  static var imageListLength = _photoDir
      .listSync()
      .map((item) => item.path)
      .where((item) => item.endsWith(".jpg"))
      .toList(growable: false)
      .length;
  @override
  State<StatefulWidget> createState() {
    return _MemeFinderState(); //create state
  }
}

class _MemeFinderState extends State<MemeFinder> {
  String res;
  bool isDetecting = false;
  List files;
  List<dynamic> preds = [];
  List<dynamic> duplicateFiles = [];
  bool isReady = false;
  Future<void> getFiles() async {
    WidgetsFlutterBinding.ensureInitialized();

    res = await Tflite.loadModel(
        model: "assets/models/model-meme.tflite",
        labels: "assets/models/labels-meme.txt",
        numThreads: 4);

    //asyn function to get list of files
    imageList = _photoDir
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith(".jpg"))
        .toList(growable: false);

    if (imageList.length != 0) {
      for (int i = 0; i < imageList.length; i++) {
        //Model to check meme
        await Tflite.runModelOnImage(
                path: imageList[i],
                imageMean: 0.0, // defaults to 117.0
                imageStd: 255.0, // defaults to 1.0
                numResults: 2, // defaults to 5
                threshold: 0.2,
                asynch: false)
            .then(
          (value) => setState(
            () {
              preds = value;
              print(preds);
              if (value[0]['confidence'] > 0.99999) {
                //if confidence is 1 then it is meme
                memes.add(imageList[i]);
                count++;
              }
            },
          ),
        );
      }
    }
    isReady = true;
  }

  deleteSelected(imgList) async {
    List<int> index = [];
    list.asMap().forEach((key, value) {
      if (value == true) {
        index.add(key);
      }
    });

    for (int i = 0; i < index.length; i++) {
      String path = imgList[index[i]];
      await File(path).delete(recursive: true);
    }
    setState(() {
      list = new List.filled(imageListLength, false, growable: true);
    });
    print(index);
  }

  void selectedImg(imgList) {
    setState(() {
      if (selected) {
        list = new List.filled(imageListLength, selected, growable: true);
      } else {
        list = new List.filled(imageListLength, selected, growable: true);
      }
      selected = !selected;
    });
  }

  @override
  void initState() {
    count = 0;
    getFiles();
    super.initState();
  }

  @override
  void dispose() {
    Tflite.close();
    memes.clear();
    imageList = [];
    count = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Meme Finder'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: list.contains(true)
                  ? () {
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
                                deleteSelected(memes);
                                Navigator.of(ctx).pop();
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
                    }
                  : null),
          IconButton(
              icon: selected
                  ? Icon(Icons.select_all)
                  : Icon(Icons.tab_unselected),
              onPressed: () {
                selectedImg(memes);
              }),
        ],
      ),
      body: !isReady
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: GridView.builder(
                      itemCount: count,
                      itemBuilder: (ctx, index) {
                        String imgPath =
                            "https://ia-discourse.s3-us-west-1.amazonaws.com/original/2X/9/97d457372f6c14182b686ecfdf5d4067df5e9373.png";
                        if (memes[index] != null) {
                          imgPath = memes[index];
                        }
                        return Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Image.file(
                              File(imgPath),
                              height: mediaQuery.size.height * 0.5,
                              width: mediaQuery.size.width * 0.5,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                            Container(
                              height: 20,
                              width: 20,
                              alignment: Alignment.topLeft,
                              child: Checkbox(
                                value: list[index],
                                onChanged: (bool value) {
                                  setState(() {
                                    list[index] = !list[index];
                                  });
                                  // print(list[index]);
                                  /* setState(() {
                                    list[index] = value;
                                    print(list[index]);
                                  }); */
                                },
                                hoverColor: Colors.red,
                              ),
                            ),
                          ],
                        );
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1 / 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
