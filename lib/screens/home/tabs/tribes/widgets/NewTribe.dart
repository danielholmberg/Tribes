import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/services/storage.dart';
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';

class NewTribe extends StatefulWidget {
  @override
  _NewTribeState createState() => _NewTribeState();
}

class _NewTribeState extends State<NewTribe> {
  String name;
  String desc;
  Color tribeColor;
  String imageURL;
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
        backgroundColor: tribeColor ?? Constants.primaryColor,
        actions: <Widget>[
          IconButton(
            color: DynamicTheme.of(context).data.buttonColor,
            icon: Icon(Icons.palette, color: Constants.buttonIconColor),
            onPressed: () {
              showDialog(
                context: context,
                child: AlertDialog(
                  title: Text('Pick a Tribe color'),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      availableColors: Constants.defaultTribeColors,
                      pickerColor: tribeColor ?? Constants.primaryColor,
                      onColorChanged: _changeColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(height: Constants.smallSpacing),
            TextFormField(
              textCapitalization: TextCapitalization.words,
              maxLength: Constants.tribeNameMaxLength,
              decoration:
                  Decorations.newTribesInput.copyWith(labelText: 'Name'),
              validator: (val) => val.isEmpty ? 'Enter a name' : null,
              onChanged: (val) {
                setState(() => name = val);
              },
            ),
            SizedBox(height: Constants.smallSpacing),
            TextFormField(
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              maxLength: Constants.tribeDescMaxLength,
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
                  dynamic success = await DatabaseService().createNewTribe(
                    name, 
                    desc, 
                    tribeColor != null ? tribeColor.value.toRadixString(16) : Constants.primaryColor.value.toRadixString(16), 
                    imageURL
                  );

                  if (success) {
                    Navigator.pop(context);
                  } else {
                    setState(() => error =
                        'Unable to create new Tribe, please try again!');
                  }
                },
              ),
            ),
            SizedBox(height: Constants.smallSpacing),
            Text(
              error,
              style: TextStyle(
                  color: Constants.errorColor,
                  fontSize: Constants.errorFontSize),
            ),
          ],
        ),
      ),
    );
  }
}
