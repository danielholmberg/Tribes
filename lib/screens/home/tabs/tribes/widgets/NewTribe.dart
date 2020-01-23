import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/constants.dart' as Constants;

class NewTribe extends StatefulWidget {
  @override
  _NewTribeState createState() => _NewTribeState();
}

class _NewTribeState extends State<NewTribe> {
  String name;
  String desc;
  Color tribeColor = Color(0xFF242424);
  bool hasImage = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    _changeColor(Color color) async {
      setState(() => tribeColor = color);
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('New Tribe'),
        backgroundColor: Constants.primaryColor,
        actions: <Widget>[
          IconButton(
            color: DynamicTheme.of(context).data.buttonColor,
            icon: Icon(Icons.color_lens, color: Constants.buttonIconColor),
            onPressed: () {
              showDialog(
                context: context,
                child: AlertDialog(
                  title: Text('Pick a Tribe color'),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: tribeColor,
                      onColorChanged: _changeColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: Decorations.newTribesInput.copyWith(labelText: 'Name'),
              validator: (val) => val.isEmpty ? 'Enter a name' : null,
              onChanged: (val) {
                setState(() => name = val);
              },
            ),
            SizedBox(height: Constants.smallSpacing),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration:
                  Decorations.newTribesInput.copyWith(labelText: 'Description'),
              validator: (val) => val.isEmpty ? 'Enter a description' : null,
              onChanged: (val) {
                setState(() => desc = val);
              },
            ),
            SizedBox(height: Constants.smallSpacing),
            ButtonTheme(
              height: 50.0,
              minWidth: MediaQuery.of(context).size.width,
              child: RaisedButton.icon(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                icon: Icon(Icons.done,
                    color: DynamicTheme.of(context).data.accentColor),
                label: Text('Create Tribe'),
                textColor: Colors.white,
                onPressed: () async {
                  dynamic result = await DatabaseService().createNewTribe(
                      name, desc, tribeColor.value.toRadixString(16), hasImage);

                  if (result == null) {
                    setState(() =>
                        error = 'Unable to create new Tribe, please try again!');
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            SizedBox(height: Constants.smallSpacing),
            Text(
              error,
              style: TextStyle(
                  color: Constants.errorColor, fontSize: Constants.errorFontSize),
            ),
          ],
        ),
      ),
    );
  }
}
