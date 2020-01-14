import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:path_provider/path_provider.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            new FlatButton(
              child: const Text('OPEN'),
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
                      print(result.paths[0]);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
