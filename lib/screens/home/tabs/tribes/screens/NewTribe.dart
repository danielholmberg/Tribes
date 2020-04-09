import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomButton.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/DiscardChangesDialog.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class NewTribe extends StatefulWidget {
  @override
  _NewTribeState createState() => _NewTribeState();
}

class _NewTribeState extends State<NewTribe> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode nameFocus = new FocusNode();
  final FocusNode descFocus = new FocusNode();
  bool loading = false;

  String name = '';
  String desc = '';
  Color tribeColor;
  bool secret = false;
  String error = '';

  bool firstToggle = true;

  @override
  void dispose() {
    nameFocus.dispose();
    descFocus.dispose();
    super.dispose();
  }

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
          child: loading ? Loading(color: tribeColor ?? Constants.primaryColor) : Scaffold(
            backgroundColor: DynamicTheme.of(context).data.backgroundColor,
            body: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: CustomScrollBehavior(),
                    child: ListView(
                      padding: EdgeInsets.only(top: 70, bottom: 36.0),
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
                                      focusNode: nameFocus,
                                      textCapitalization: TextCapitalization.words,
                                      maxLength: Constants.tribeNameMaxLength,
                                      cursorColor: tribeColor ?? Constants.primaryColor,
                                      decoration: Decorations.newTribeInput.copyWith(
                                        labelText: 'Name',
                                        labelStyle: TextStyle(
                                          color: tribeColor ?? Constants.inputLabelColor,
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        hintText: '',
                                        counterStyle: TextStyle(
                                          color: (tribeColor ?? Constants.primaryColor).withOpacity(0.5) ?? Constants.inputCounterColor,
                                          fontFamily: 'TribesRounded',
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(color: (tribeColor ?? Constants.primaryColor).withOpacity(0.5) ?? Constants.inputEnabledColor, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(
                                            color: tribeColor ?? Constants.inputFocusColor, 
                                            width: 2.0
                                          ),
                                        )
                                      ),
                                      validator: (val) => val.isEmpty ? 'Enter a name' : null,
                                      onChanged: (val) {
                                        setState(() => name = val);
                                      },
                                      onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(descFocus),
                                    ),
                                    SizedBox(height: Constants.smallSpacing),
                                    TextFormField(
                                      focusNode: descFocus,
                                      textCapitalization: TextCapitalization.sentences,
                                      keyboardType: TextInputType.multiline,
                                      maxLength: Constants.tribeDescMaxLength,
                                      maxLines: null,
                                      decoration: Decorations.newTribeInput.copyWith(
                                        labelText: 'Description',
                                        labelStyle: TextStyle(
                                          color: tribeColor ?? Constants.inputLabelColor,
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.normal,
                                        ),
                                        hintText: '',
                                        counterStyle: TextStyle(
                                          color: (tribeColor ?? Constants.primaryColor).withOpacity(0.5) ?? Constants.inputCounterColor,
                                          fontFamily: 'TribesRounded',
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(color: (tribeColor ?? Constants.primaryColor).withOpacity(0.5) ?? Constants.inputEnabledColor, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(
                                            color: tribeColor ?? Constants.inputFocusColor, 
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
                Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    margin: EdgeInsets.all(12.0),
                    elevation: 8.0,
                    child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Leading Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Platform.isIOS ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.arrowLeft,
                                color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                              ), 
                              onPressed: () {
                                if(name.isNotEmpty || desc.isNotEmpty || tribeColor != null || secret) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => DiscardChangesDialog(color: tribeColor)
                                  );
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        ),

                        SizedBox(width: Constants.defaultPadding),

                        // Center Widget
                        Expanded(
                          child: Text('New Tribe',
                            style: TextStyle(
                              color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                              fontFamily: 'TribesRounded',
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
                        ),

                        // Trailing Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: CustomAwesomeIcon(
                                icon: secret ? FontAwesomeIcons.solidEyeSlash : FontAwesomeIcons.eye, 
                                color: (tribeColor ?? Constants.primaryColor).withOpacity(secret ? 0.6 : 1.0),
                              ),
                              onPressed: () {
                                if(firstToggle) {
                                  setState(() => firstToggle = false);

                                  showDialog(
                                    context: context,
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                                      title: Text('Secret Tribe',
                                        style: TextStyle(
                                          fontFamily: 'TribesRounded',
                                          fontWeight: Constants.defaultDialogTitleFontWeight,
                                          fontSize: Constants.defaultDialogTitleFontSize,
                                        ),
                                      ),
                                      content: Container(
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'This will make your Tribe',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'TribesRounded'
                                            ),
                                            children: <TextSpan>[
                                              TextSpan(text: ' secret ', 
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: 'TribesRounded', 
                                                  fontStyle: FontStyle.italic
                                                ),
                                              ),
                                              TextSpan(text: 'and can only be found by typing in the', 
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: 'TribesRounded'
                                                ),
                                              ),
                                              TextSpan(text: ' exact ', 
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: 'TribesRounded', 
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              TextSpan(text: 'Tribe name.', 
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: 'TribesRounded'
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } 
                                setState(() => secret = !secret);
                              },
                            ),
                            IconButton(
                              icon: CustomAwesomeIcon(icon: FontAwesomeIcons.palette, color: tribeColor ?? Constants.primaryColor),
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

                      ],
                    ),
                  ),
                  /* ListTile(
                      contentPadding: EdgeInsets.only(left: 16.0, right: 12.0),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: CustomAwesomeIcon(
                              icon: Platform.isIOS ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.arrowLeft,
                              color: tribeColor ?? Constants.primaryColor,
                            ), 
                            onPressed: () {
                              if(name.isNotEmpty || desc.isNotEmpty || tribeColor != null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => DiscardChangesDialog(color: tribeColor)
                                );
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ],
                      ),
                      title: Text('New Tribe', 
                        style: TextStyle(
                          color: tribeColor ?? DynamicTheme.of(context).data.primaryColor,
                          fontFamily: 'TribesRounded',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: CustomAwesomeIcon(
                              icon: secret ? FontAwesomeIcons.solidEyeSlash : FontAwesomeIcons.eye, 
                              color: (tribeColor ?? Constants.primaryColor).withOpacity(secret ? 0.6 : 1.0),
                            ),
                            onPressed: () {
                              if(firstToggle) {
                                setState(() => firstToggle = false);

                                showDialog(
                                  context: context,
                                  child: AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                                    title: Text('Secret Tribe',
                                      style: TextStyle(
                                        fontFamily: 'TribesRounded',
                                        fontWeight: Constants.defaultDialogTitleFontWeight,
                                        fontSize: Constants.defaultDialogTitleFontSize,
                                      ),
                                    ),
                                    content: Container(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'This will make your Tribe',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'TribesRounded'
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(text: ' secret ', 
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'TribesRounded', 
                                                fontStyle: FontStyle.italic
                                              ),
                                            ),
                                            TextSpan(text: 'and can only be found by typing in the', 
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'TribesRounded'
                                              ),
                                            ),
                                            TextSpan(text: ' exact ', 
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'TribesRounded', 
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            TextSpan(text: 'Tribe name.', 
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'TribesRounded'
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } 
                              setState(() => secret = !secret);
                            },
                          ),
                          IconButton(
                            icon: CustomAwesomeIcon(icon: FontAwesomeIcons.palette, color: tribeColor ?? Constants.primaryColor),
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
                    ), */
                  ),
                ),
                Positioned(
                  bottom: Platform.isIOS ? 8.0 : 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: (name.isEmpty || desc.isEmpty) ? SizedBox.shrink() : AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: (name.isNotEmpty && desc.isNotEmpty) ? 1.0 : 0.0,
                      child: CustomButton(
                        height: 60.0,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.all(16.0),
                        icon: FontAwesomeIcons.check,
                        iconColor: Colors.white,
                        color: Colors.green,
                        label: Text('Create', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
                        labelColor: Colors.white,
                        onPressed: () async {                
                          if(_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            try {
                              DatabaseService().createNewTribe(
                                currentUser.uid,
                                name, 
                                desc, 
                                tribeColor != null ? tribeColor.value.toRadixString(16) : Constants.primaryColor.value.toRadixString(16), 
                                null,
                                secret,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
