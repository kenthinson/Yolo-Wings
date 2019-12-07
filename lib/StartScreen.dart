import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
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
              onPressed: () {},
              color: Colors.blue,
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
              onPressed: null,
              color: Colors.blue,
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
              onPressed: null,
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
