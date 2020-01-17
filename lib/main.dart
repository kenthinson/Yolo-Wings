import 'dart:async';
import 'dart:io';
import 'package:xml/xml.dart' as xml;

import 'package:flutter/material.dart';
import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'SearchDialogWidget.dart';
import 'annotation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> classNames = ["Yoda", "Chewy", "Han", "Luke"];
  final FocusNode _focusNode = FocusNode();
  var crosshairOffsetLeft = 0.0;
  var crosshairOffsetTop = 0.0;
  var lastClassNameChoses = 0;
  var overlayShowing = false;
  var imageindex = 0;

  List<String> imagePaths = [""];

  Annotation newAnnotaton;
  List<Annotation> currentImageAnnotations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.blue,
            height: 40,
            child: Row(
              children: <Widget>[
                IconButton(icon: Icon(Icons.list), onPressed: (){}, tooltip: 'Select Label Map',),
                IconButton(
                  onPressed: () async {
                    String initialDirectory;
                    if (Platform.isMacOS) {
                      initialDirectory =
                          (await getApplicationDocumentsDirectory()).path;
                    }
                    file_chooser
                        .showOpenPanel(
                            allowsMultipleSelection: false,
                            initialDirectory: initialDirectory,
                            canSelectDirectories: true)
                        .then(
                      (result) {
                        if (result.canceled) {
                          print('canceled');
                        } else {
                          imagePaths = [];
                          var dir = Directory(result.paths[0]);
                          var lister = dir.list(recursive: false);
                          List<String> filePaths = [];
                          lister.listen((file) {
                            if (extension(file.path) == ".jpg" ||
                                extension(file.path) == ".jpeg") {
                              filePaths.add(file.path);
                            }
                          }, onDone: () {
                            setState(() {
                              imagePaths = filePaths;
                            });
                              currentImageAnnotations = loadXMLAnnotations(imagePaths[imageindex]);
                          });
                        }
                      },
                    );
                  },
                  icon: Icon(Icons.filter),
                  tooltip: 'Open Images Folder',
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: (imageindex != 0)
                      ? () {
                          setState(() {
                            imageindex--;
                          });
                          currentImageAnnotations = loadXMLAnnotations(imagePaths[imageindex]);
                        }
                      : null,
                  tooltip: 'Back a Image',
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),
                  onPressed: (imageindex != imagePaths.length - 1)
                      ? () {
                          setState(() {
                            imageindex++;
                            currentImageAnnotations= loadXMLAnnotations(imagePaths[imageindex]);
                          });
                        }
                      : null,
                  tooltip: 'Next Image',
                )
              ],
            ),
          ),
          RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (event) {
              if (event.runtimeType == RawKeyDownEvent) {
                if (event.data.logicalKey.debugName == "Backspace") {
                  if (currentImageAnnotations.length > 0) {
                    setState(() {
                      currentImageAnnotations.removeLast();
                    });
                  }
                }
              }
            },
            child: Listener(
              onPointerMove: (event) {
                setState(() {
                  crosshairOffsetLeft = event.localPosition.dx;
                  crosshairOffsetTop = event.localPosition.dy;
                  if (newAnnotaton != null) {
                    setState(() {
                      newAnnotaton.point2 = event.localPosition;
                    });
                  }
                });
              },
              onPointerUp: (event) {
                newAnnotaton = null;
              },
              onPointerDown: (event) {
                setState(() {
                  crosshairOffsetLeft = event.localPosition.dx;
                  crosshairOffsetTop = event.localPosition.dy;
                });
              },
              child: MouseRegion(
                onHover: (event) {
                  setState(() {
                    crosshairOffsetLeft = event.localPosition.dx;
                    crosshairOffsetTop = event.localPosition.dy;
                  });
                },
                child: Stack(
                  children: <Widget>[
                    Image.file(File(imagePaths[imageindex])),
                    Positioned(
                        top: 0,
                        bottom: 0,
                        width: 1,
                        left: crosshairOffsetLeft,
                        child: Container(
                          color: Colors.red,
                        )),
                    Positioned(
                        left: 0,
                        right: 0,
                        height: 1,
                        top: crosshairOffsetTop,
                        child: Container(
                          color: Colors.red,
                        )),
                    Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        top: 0,
                        child: Listener(
                          onPointerDown: (event) {
                            newAnnotaton = Annotation(
                                event.localPosition, event.localPosition, 0);
                            setState(() {
                              currentImageAnnotations.add(newAnnotaton);
                            });
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0),
                          ),
                        )),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: Builder(
                        builder: (context) {
                          List<Widget> annotationBoxes = currentImageAnnotations
                              .map((data) => buildAnnotation(context, data))
                              .toList();
                          return Stack(
                            children: annotationBoxes,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stack buildAnnotation(BuildContext context, Annotation annotation) {
    var index = currentImageAnnotations.indexOf(annotation);
    var isFront = (index == currentImageAnnotations.length - 1);
    var color = isFront ? Colors.green : Colors.red;
    return Stack(
      children: <Widget>[
        Positioned(
          child: Container(
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: GestureDetector(
                    child: Container(
                      color: Colors.black.withOpacity(0.0),
                    ),
                    onTapDown: (event) {
                      bringToFront(annotation);
                    },
                  ),
                ),
                Align(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
                    child: GestureDetector(
                      child: Text(classNames[annotation.label]),
                      onTapDown: (event) {
                        if (isFront) {
                          overlayShowing = true;
                          showDialog(
                              context: context,
                              builder: (_) =>
                                  SearchDialogWidget(classNames)).then((value) {
                            if (value != null) {
                              if (!classNames.contains(value)) {
                                classNames.add(value);
                              }
                              setState(() {
                                annotation.label = classNames.indexOf(value);
                              });
                            }
                            overlayShowing = false;
                          });
                        } else {
                          bringToFront(annotation);
                        }
                      },
                    ),
                    color: color,
                  ),
                  alignment: Alignment.topCenter,
                ),
                Positioned(
                  child: Container(
                    color: color,
                  ),
                  top: 0,
                  bottom: 0,
                  left: 0,
                  width: 2,
                ),
                Positioned(
                  child: Container(
                    color: color,
                  ),
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: 2,
                ),
                Positioned(
                  child: Container(
                    color: color,
                  ),
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 2,
                ),
                Positioned(
                  child: Container(
                    color: color,
                  ),
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 2,
                ),
              ],
            ),
          ),
          top: annotation.point1.dy <= annotation.point2.dy
              ? annotation.point1.dy
              : annotation.point2.dy,
          left: annotation.point1.dx <= annotation.point2.dx
              ? annotation.point1.dx
              : annotation.point2.dx,
          width: annotation.point1.dx <= annotation.point2.dx
              ? annotation.point2.dx - annotation.point1.dx
              : annotation.point1.dx - annotation.point2.dx,
          height: annotation.point1.dy <= annotation.point2.dy
              ? annotation.point2.dy - annotation.point1.dy
              : annotation.point1.dy - annotation.point2.dy,
        ),
        Positioned(
          top: annotation.point1.dy - 5,
          left: annotation.point1.dx - 5,
          height: 10,
          width: 10,
          child: Listener(
            child: Container(
              color: color,
            ),
            onPointerMove: isFront
                ? (event) {
                    setState(() {
                      annotation.point1 =
                          Offset(crosshairOffsetLeft, crosshairOffsetTop);
                    });
                  }
                : null,
          ),
        ),
        Positioned(
          top: annotation.point2.dy - 5,
          left: annotation.point1.dx - 5,
          height: 10,
          width: 10,
          child: Listener(
            child: Container(
              color: color,
            ),
            onPointerMove: isFront
                ? (event) {
                    setState(() {
                      annotation.point2 =
                          Offset(annotation.point2.dx, crosshairOffsetTop);
                      annotation.point1 =
                          Offset(crosshairOffsetLeft, annotation.point1.dy);
                    });
                  }
                : null,
          ),
        ),
        Positioned(
          top: annotation.point1.dy - 5,
          left: annotation.point2.dx - 5,
          height: 10,
          width: 10,
          child: Listener(
            child: Container(
              color: color,
            ),
            onPointerMove: isFront
                ? (event) {
                    setState(() {
                      annotation.point1 =
                          Offset(annotation.point1.dx, crosshairOffsetTop);
                      annotation.point2 =
                          Offset(crosshairOffsetLeft, annotation.point2.dy);
                    });
                  }
                : null,
          ),
        ),
        Positioned(
          top: annotation.point2.dy - 5,
          left: annotation.point2.dx - 5,
          height: 10,
          width: 10,
          child: Listener(
            child: Container(
              color: color,
            ),
            onPointerMove: isFront
                ? (event) {
                    setState(() {
                      annotation.point2 =
                          Offset(crosshairOffsetLeft, crosshairOffsetTop);
                    });
                  }
                : null,
          ),
        ),
      ],
    );
  }

  bringToFront(Annotation annotation) {
    setState(() {
      currentImageAnnotations.remove(annotation);
      currentImageAnnotations.add(annotation);
    });
  }
}

List<Annotation> loadXMLAnnotations(String imgPath) {
  var xmlPath = withoutExtension(imgPath) + '.xml';
  var xmlFile = File(xmlPath);
  if (xmlFile.existsSync()) {
    var xmlString = xmlFile.readAsStringSync();
    var xmlData = xml.parse(xmlString);
    var objects = xmlData.findAllElements('object').toList();
    print(objects[0].text);
  }
  return [];
}
