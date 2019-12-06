import 'package:flutter/material.dart';

class SearchDialogWidget extends StatefulWidget {
  List<String> classNames;
  SearchDialogWidget(List<String> classNames) : this.classNames = classNames;

  @override
  _SearchDialogWidgetState createState() => _SearchDialogWidgetState();
}

class _SearchDialogWidgetState extends State<SearchDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      content: Builder(
        builder: (context) {
          return Container(
            height: 800,
            width: 500,
            child: Column(
              children: <Widget>[
                TextField(
                  autofocus: true,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('Gujarat, India'),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
