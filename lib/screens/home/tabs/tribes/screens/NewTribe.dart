import 'dart:io';

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

  String name = '';
  String desc = '';
  Color tribeColor;
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
              leading: IconButton(icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back), 
                color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                onPressed: () {
                  if(name.isNotEmpty || desc.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                        backgroundColor: Constants
                            .profileSettingsBackgroundColor,
                        title: Text('Are your sure you want to discard changes?',
                          style: TextStyle(
                            fontFamily: 'TribesRounded',
                            fontWeight: Constants.defaultDialogTitleFontWeight,
                            fontSize: Constants.defaultDialogTitleFontSize,
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('No', 
                              style: TextStyle(
                                color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                fontFamily: 'TribesRounded',
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('Yes',
                              style: TextStyle(
                                color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                                fontFamily: 'TribesRounded',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Dialog: "Are you sure...?"
                              Navigator.of(context).pop(); // NewPost
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
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
            body: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: CustomScrollBehavior(),
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 20.0),
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          fontWeight: FontWeight.normal,
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
                                  ]
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: (name.isNotEmpty || desc.isNotEmpty) ? 1.0 : 0.0,
                      child: ButtonTheme(
                      height: 60.0,
                      minWidth: MediaQuery.of(context).size.width,
                      child: RaisedButton.icon(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                        ),
                        color: Colors.green,
                        icon: Icon(Icons.done, color: Constants.buttonIconColor, size: Constants.defaultIconSize),
                        label: Text('Create', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
                        textColor: Colors.white,
                        onPressed: () async {                
                          if(_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            try {
                              DatabaseService().createNewTribe(
                                currentUser.uid,
                                name, 
                                desc, 
                                tribeColor != null ? tribeColor.value.toRadixString(16) : Constants.primaryColor.value.toRadixString(16), 
                                null
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
                        }
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
