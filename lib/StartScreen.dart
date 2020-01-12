import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

import 'main.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  var imagePaths = [];
  var annotationPaths = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                  side: BorderSide(color: Colors.white)),
              onPressed: () {
                FilePicker.getFilePath().then((pathString) {
                  if (pathString != "") {
                    var dirPath = path.dirname(pathString);
                    var dir = Directory(dirPath);
                    var lister = dir.list(recursive: false);
                    List<String> filePaths = [];
                    lister.listen((file) {
                      filePaths.add(file.path);
                    }, onDone: () {
                      setState(() {
                        imagePaths = filePaths;
                      });
                    });
                  }
                });
              },
              color: imagePaths.length == 0 ? Colors.blue : Colors.lightGreen,
              padding: EdgeInsets.all(8.0),
              textColor: Colors.white,
              child: Text("1. Select images folder.".toUpperCase(),
                  style: TextStyle(fontSize: 30)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                  side: BorderSide(color: Colors.white)),
              onPressed: imagePaths.length == 0
                  ? null
                  : () {
                      FilePicker.getFilePath().then((pathString) {
                        if (pathString != "") {
                          var dirPath = path.dirname(pathString);
                          var dir = Directory(dirPath);
                          var lister = dir.list(recursive: false);
                          List<String> filePaths = [];
                          lister.listen((file) {
                            filePaths.add(file.path);
                          }, onDone: () {
                            setState(() {
                              annotationPaths = filePaths;
                            });
                          });
                        }
                      });
                    },
              color:
                  annotationPaths.length == 0 ? Colors.blue : Colors.lightGreen,
              padding: EdgeInsets.all(10.0),
              textColor: Colors.white,
              child: Text("2. Select annotations folder.".toUpperCase(),
                  style: TextStyle(fontSize: 30)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                  side: BorderSide(color: Colors.white)),
              onPressed: (imagePaths.length == 0 || annotationPaths.length == 0)
                  ? null
                  : () {
                      FilePicker.getFilePath();
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => MyHomePage()),
                      // );
                    },
              color: Colors.blue,
              padding: EdgeInsets.all(10.0),
              textColor: Colors.white,
              child: Text("3. Select class defenations file.".toUpperCase(),
                  style: TextStyle(fontSize: 30)),
            ),
          ),
        ],
      ),
    );
  }
}
