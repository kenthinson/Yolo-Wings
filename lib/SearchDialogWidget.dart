import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchDialogWidget extends StatefulWidget {
  List<String> classNames;
  SearchDialogWidget(List<String> classNames) : this.classNames = classNames;

  @override
  _SearchDialogWidgetState createState() => _SearchDialogWidgetState();
}

class _SearchDialogWidgetState extends State<SearchDialogWidget> {

  var textFocusNode = FocusNode();
  var controller = TextEditingController();
  var lastTyped = "";
  List<String> filteredClassNames;

  @override
  void initState() {
    super.initState();
    filteredClassNames = widget.classNames;
  }
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
                  focusNode: textFocusNode,
                  autofocus: true,
                  controller: controller,
                  onChanged: (text){
                    setState(() {
                    filteredClassNames = widget.classNames.where((name) => name.toLowerCase().startsWith(text.toLowerCase())).toList();
                    });
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredClassNames.length,
                  itemBuilder: (BuildContext context, int index) {
                    var fn = FocusNode();
                    fn.addListener((){
                      if (fn.hasFocus){
                        controller.text = filteredClassNames[index];
                      }
                    });
                    return MaterialButton(
                      onPressed: (){
                        FocusScope.of(context).requestFocus(textFocusNode);
                      },
                      focusNode: fn,
                      child: Text(filteredClassNames[index]),
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
