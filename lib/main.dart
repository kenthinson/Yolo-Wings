import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

List<String> classNames = ["Yoda", "Chewy", "Han", "Luke"];

class _MyHomePageState extends State<MyHomePage> {
  final FocusNode _focusNode = FocusNode();
  var path = "";
  var crosshairOffsetLeft = 0.0;
  var crosshairOffsetTop = 0.0;
  var lastClassNameChoses = 0;
  var overlayShowing = false;
  Annotation newAnnotaton;
  List<Annotation> currentImageAnnotations = [
    Annotation(Offset(10, 10), Offset(100, 100), 0),
    Annotation(Offset(500, 500), Offset(600, 600), 1),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!overlayShowing) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.file_upload),
          onPressed: () {
            FilePicker.getFilePath().then((onValue) {
              setState(() {
                path = onValue;
              });
            });
          },
        )
      ],
      title: Text(widget.title),
    );
    return Scaffold(
      appBar: appBar,
      body: RawKeyboardListener(
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
                crosshairOffsetTop =
                    event.localPosition.dy - appBar.preferredSize.height;
              });
            },
            child: Stack(
              children: <Widget>[
                Image.file(File(path)),
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
                      onTapDown: 
                          (event) {
                            if(isFront){
                              overlayShowing = true;
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        content: Builder(
                                          builder: (context) {
                                            var height = MediaQuery.of(context)
                                                .size
                                                .height;
                                            var width = MediaQuery.of(context)
                                                .size
                                                .width;
                                            return Container(
                                              height: 800,
                                              width: 500,
                                              child: TextField(
                                                autofocus: true,
                                              ),
                                            );
                                          },
                                        ),
                                      )).then((value) {
                                overlayShowing = false;
                              });
                            }else{
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

class Annotation {
  Offset point1;
  Offset point2;
  int label;
  Annotation(p1, p2, label) {
    this.point1 = p1;
    this.point2 = p2;
    this.label = label;
  }
}
