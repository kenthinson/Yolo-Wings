import 'package:flutter/material.dart';

class SearchDialogWidget extends StatelessWidget {
  const SearchDialogWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      content: Builder(
        builder: (context) {
          var height = MediaQuery.of(context).size.height;
          var width = MediaQuery.of(context).size.width;
          return Container(
            height: 800,
            width: 500,
            child: TextField(
              autofocus: true,
            ),
          );
        },
      ),
    );
  }
}
