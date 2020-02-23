import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class NewTribe extends StatefulWidget {
  @override
  _NewTribeState createState() => _NewTribeState();
}

class _NewTribeState extends State<NewTribe> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String name;
  String desc;
  Color tribeColor;
  String imageURL;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building NewTribe()...');
    print('Current user ${currentUser.toString()}');

    _changeColor(Color color) async {
      setState(() => tribeColor = color);
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.pop(context);
    }

    return WillPopScope(
      onWillPop: () {
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.of(context).pop();
        return;
      },
        child: Container(
        color: DynamicTheme.of(context).data.primaryColor,
        child: SafeArea(
          bottom: false,
          child: loading ? Loading() : Scaffold(
            backgroundColor: DynamicTheme.of(context).data.backgroundColor,
            appBar: AppBar(
              elevation: 0.0,
              centerTitle: true,
              title: Text('New Tribe', 
                style: TextStyle(
                  color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: DynamicTheme.of(context).data.backgroundColor,
              iconTheme: IconThemeData(color: tribeColor ?? DynamicTheme.of(context).data.primaryColor),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.palette),
                  onPressed: () {
                    showDialog(
                      context: context,
                      child: AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                        title: Text('Pick a Tribe color',
                          style: TextStyle(
                            fontFamily: 'TribesRounded',
                            fontWeight: Constants.defaultDialogTitleFontWeight,
                            fontSize: Constants.defaultDialogTitleFontSize,
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            availableColors: Constants.defaultTribeColors,
                            pickerColor: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
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
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(16.0),
                  shrinkWrap: true,
                  children: <Widget>[
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      maxLength: Constants.tribeNameMaxLength,
                      cursorColor: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                      decoration: Decorations.postContentInput.copyWith(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                          fontFamily: 'TribesRounded',
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: '',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: tribeColor ?? DynamicTheme.of(context).data.primaryColor, 
                            width: 2.0
                          ),
                        )
                      ),
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
                      decoration: Decorations.postContentInput.copyWith(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                          fontFamily: 'TribesRounded',
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: '',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide(
                            color: tribeColor ?? DynamicTheme.of(context).data.primaryColor, 
                            width: 2.0
                          ),
                        )
                      ),
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
                        label: Text('Create Tribe', 
                          style: TextStyle(
                            fontFamily: 'TribesRounded',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        textColor: Colors.white,
                        onPressed: () {
                          if(_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            try {
                              DatabaseService().createNewTribe(
                                currentUser.uid,
                                name, 
                                desc, 
                                tribeColor != null ? tribeColor.value.toRadixString(16) : Constants.primaryColor.value.toRadixString(16), 
                                imageURL
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              print(e.toString());
                              setState(() { 
                                loading = false;
                                error = 'Unable to create new Tribe';
                              });
                            }
                          }
                        },
                      ),
                    ),
                    SizedBox(height: Constants.smallSpacing),
                    Center(
                      child: Text(
                        error,
                        style: TextStyle(
                          color: Constants.errorColor,
                          fontSize: Constants.errorFontSize,
                          fontFamily: 'TribesRounded',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
