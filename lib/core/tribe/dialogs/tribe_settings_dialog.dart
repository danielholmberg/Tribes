import 'dart:io';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/services/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_button.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/discard_changes_dialog.dart';
import 'package:tribes/shared/widgets/loading.dart';

class TribeSettingsDialog extends StatefulWidget {
  final Tribe tribe;
  final Function onSave;
  TribeSettingsDialog({@required this.tribe, @required this.onSave});

  @override
  _TribeSettingsDialogState createState() => _TribeSettingsDialogState();
}

class _TribeSettingsDialogState extends State<TribeSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode nameFocus = new FocusNode();
  final FocusNode descFocus = new FocusNode();
  final FocusNode passwordFocus = new FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool firstToggle = true;
  bool edited = false;

  String name;
  String desc;
  Color tribeColor;
  String password;
  String imageURL;
  bool secret;
  String error = '';

  String originalName;
  String originalDesc;
  Color originalTribeColor;
  String originalPassword;
  bool originalSecret;

  @override
  void initState() {
    originalName = widget.tribe.name;
    originalDesc = widget.tribe.desc;
    originalTribeColor = widget.tribe.color;
    originalPassword = widget.tribe.password;
    originalSecret = widget.tribe.secret;
    name = originalName;
    desc = originalDesc;
    tribeColor = originalTribeColor;
    password = originalPassword;
    secret = originalSecret;

    super.initState();
  }

  @override
  void dispose() {
    nameFocus.dispose();
    descFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    edited = originalName != name || originalDesc != desc || originalPassword != password || originalTribeColor != tribeColor || originalSecret != secret;

    _changeColor(Color color) async {
      setState(() => tribeColor = color);
      await Future.delayed(Duration(milliseconds: 300));
      Navigator.pop(context);
    }

    _onPressDeleteButton() {
      setState(() => loading = true);

      Navigator.of(context).popUntil((route) => route.isFirst);
      DatabaseService().deleteTribe(widget.tribe.id);
    }

    _buildAppBar(Tribe currentTribe) {
      return AppBar(
        elevation: 0.0,
        backgroundColor: DynamicTheme.of(context).data.backgroundColor,
        leading: IconButton(
          icon: CustomAwesomeIcon(
            icon: Platform.isIOS ? FontAwesomeIcons.chevronLeft : FontAwesomeIcons.arrowLeft, 
            color: tribeColor != null ? tribeColor : currentTribe.color,
          ),
          splashColor: Colors.transparent,
          onPressed: () {
            bool edited = originalName != name || originalDesc != desc || originalTribeColor != tribeColor;
            if(edited) {
              showDialog(
                context: context,
                builder: (context) => DiscardChangesDialog()
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: tribeColor != null ? tribeColor : currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
            fontFamily: 'TribesRounded',
            fontSize: Constants.defaultDialogTitleFontSize,
            fontWeight: Constants.defaultDialogTitleFontWeight
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: CustomAwesomeIcon(
              icon: secret ? FontAwesomeIcons.solidEyeSlash : FontAwesomeIcons.eye, 
              color: (tribeColor ?? Constants.primaryColor).withOpacity(secret ? 0.6 : 1.0),
            ),
            onPressed: () {
              if(firstToggle && !originalSecret) {
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
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Abort', 
                          style: TextStyle(
                            color: currentTribe.color,
                            fontFamily: 'TribesRounded',
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('OK', 
                          style: TextStyle(
                            color: currentTribe.color,
                            fontFamily: 'TribesRounded',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          setState(() => secret = !secret);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
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
              } else {
                setState(() => secret = !secret);
              }
            },
          ),
          IconButton(
            icon: CustomAwesomeIcon(icon: FontAwesomeIcons.palette, color: tribeColor != null ? tribeColor : currentTribe.color), 
            onPressed: () => showDialog(
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
                    pickerColor: tribeColor ?? Constants.primaryColor,
                    onColorChanged: _changeColor,
                  ),
                ),
              ),
            )
          ),
          SizedBox(width: 4.0,)
        ],
      );
    }

    _buildDeleteTribeButton(Tribe currentTribe) {
      return Align(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                bool isDeleteButtonDisabled = true;

                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                      backgroundColor: Constants.profileSettingsBackgroundColor,
                      title: RichText(
                        text: TextSpan(
                          text: 'Please type ',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'TribesRounded',
                            fontWeight: FontWeight.normal
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: currentTribe.name,
                              style: TextStyle(
                                fontFamily: 'TribesRounded',
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            TextSpan(
                              text: ' to delete this Tribe.',
                              style: TextStyle(
                                fontFamily: 'TribesRounded',
                                fontWeight: FontWeight.normal
                              ),
                            ),
                          ],
                        ),
                      ),
                      content: Container(
                        child: TextFormField(
                          cursorRadius: Radius.circular(1000),
                          textCapitalization: TextCapitalization.words,
                          decoration: Decorations.tribeSettingsInput.copyWith(
                            hintText: currentTribe.name,
                            labelStyle: TextStyle(
                              color: tribeColor ?? Constants.inputLabelColor,
                              fontFamily: 'TribesRounded',
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: tribeColor.withOpacity(0.5) ?? Constants.inputEnabledColor, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                color: tribeColor ?? Constants.inputFocusColor, 
                                width: 2.0
                              ),
                            )
                          ),
                          onChanged: (val) {
                            if (val == currentTribe.name) {
                              setState(() => isDeleteButtonDisabled = false);
                            } else {
                              setState(() => isDeleteButtonDisabled = true);
                            }
                          },
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Cancel', 
                            style: TextStyle(
                              color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                              fontFamily: 'TribesRounded',
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // Dialog: "Please type..."
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: isDeleteButtonDisabled ? Colors.black54 : Colors.red,
                              fontFamily: 'TribesRounded',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: isDeleteButtonDisabled ? null : _onPressDeleteButton,
                        ),
                      ],
                    );
                  }
                );
              }
            );
          },
          child: Text(
            'Delete Tribe',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'TribesRounded',
                color: Colors.red),
          ),
        ),
      );
    }

    _buildSaveButton(Tribe currentTribe) {
      return Visibility(
        visible: edited,
        child: CustomButton(
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(16.0),
          color: Colors.green,
          icon: FontAwesomeIcons.check,
          label: Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
          labelColor: Colors.white,
          onPressed: edited ? () {
            if (_formKey.currentState.validate()) {
              print('Updating Tribe information...');
              setState(() => loading = true);

              DatabaseService().updateTribeData(
                currentTribe.id,
                name ?? currentTribe.name,
                desc ?? currentTribe.desc,
                tribeColor != null
                    ? tribeColor.value
                        .toRadixString(16)
                    : currentTribe.color.value
                            .toRadixString(16) ??
                        Constants.primaryColor.value
                            .toRadixString(16),
                password ?? currentTribe.password,
                imageURL,
                secret,
              );

              _scaffoldKey.currentState
                  .showSnackBar(SnackBar(
                content: Text('Tribe settings saved!',
                  style: TextStyle(
                    fontFamily: 'TribesRounded',
                  ),
                ),
                duration: Duration(milliseconds: 500),
              ));

              setState(() {
                loading = false;
                originalName = name;
                originalDesc = desc;
                originalTribeColor = tribeColor;
                originalPassword = password;
                originalSecret = secret;
              });

              widget.onSave(
                widget.tribe.copyWith(name: name, desc: desc, color: tribeColor, password: password, secret: secret)
              );
            }
          } : null,
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
      contentPadding: EdgeInsets.zero,
      content: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * (edited ? 0.65 : 0.55),
          alignment: Alignment.topCenter,
          child: StreamBuilder<Tribe>(
            stream: DatabaseService().tribe(widget.tribe.id),
            builder: (context, snapshot) {
              Tribe currentTribe = snapshot.hasData ? snapshot.data : widget.tribe;

              return loading ? Loading(color: currentTribe.color ?? widget.tribe.color) 
              : Scaffold(
                key: _scaffoldKey,
                backgroundColor: DynamicTheme.of(context).data.backgroundColor,
                appBar: _buildAppBar(currentTribe),
                body: ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: ListView(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, edited ? 92.0 : 16.0),
                          children: <Widget>[
                            Container(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    TextFormField(
                                      focusNode: nameFocus,
                                      cursorRadius: Radius.circular(1000),
                                      initialValue: currentTribe.name,
                                      maxLength: Constants.tribeNameMaxLength,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: Decorations.tribeSettingsInput.copyWith(
                                        labelText: 'Name',
                                        labelStyle: TextStyle(
                                          color: tribeColor ?? Constants.inputLabelColor,
                                          fontFamily: 'TribesRounded',
                                        ),
                                        hintText: 'Tribe name',
                                        counterStyle: TextStyle(color: tribeColor.withOpacity(0.5) ?? Constants.inputCounterColor, fontFamily: 'TribesTrounded'),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(color: tribeColor.withOpacity(0.5) ?? Constants.inputEnabledColor, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(
                                            color: tribeColor ?? Constants.inputFocusColor, 
                                            width: 2.0
                                          ),
                                        )
                                      ),
                                      validator: (val) => val.isEmpty ? 'Please add a name' : null,
                                      onChanged: (val) {
                                        setState(() => name = val);
                                      },
                                      onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(descFocus),
                                    ),
                                    SizedBox(height: Constants.smallSpacing),
                                    TextFormField(
                                      focusNode: descFocus,
                                      cursorRadius: Radius.circular(1000),
                                      initialValue: currentTribe.desc,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      keyboardType: TextInputType.multiline,
                                      maxLength: Constants.tribeDescMaxLength,
                                      maxLines: null,
                                      decoration: Decorations.tribeSettingsInput.copyWith(
                                        labelText: 'Description',
                                        labelStyle: TextStyle(
                                          color: tribeColor ?? Constants.inputLabelColor,
                                          fontFamily: 'TribesRounded',
                                        ),
                                        hintText: 'Descriptive text',
                                        counterStyle: TextStyle(color: tribeColor.withOpacity(0.5) ?? Constants.inputCounterColor, fontFamily: 'TribesTrounded'),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(color: tribeColor.withOpacity(0.5) ?? Constants.inputEnabledColor, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(
                                            color: tribeColor ?? Constants.inputFocusColor, 
                                            width: 2.0
                                          ),
                                        )
                                      ),
                                      onChanged: (val) {
                                        setState(() => desc = val);
                                      },
                                    ),
                                    SizedBox(height: Constants.smallSpacing),
                                    TextFormField(
                                      focusNode: passwordFocus,
                                      cursorRadius: Radius.circular(1000),
                                      initialValue: currentTribe.password,
                                      textCapitalization: TextCapitalization.sentences,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      maxLines: null,
                                      validator: (val) => val.length != 6 ? 'Password must be 6 digits' : null,
                                      inputFormatters: <TextInputFormatter>[
                                        WhitelistingTextInputFormatter.digitsOnly
                                      ],
                                      decoration: Decorations.tribeSettingsInput.copyWith(
                                        labelText: 'Password',
                                        labelStyle: TextStyle(
                                          color: tribeColor ?? Constants.inputLabelColor,
                                          fontFamily: 'TribesRounded',
                                        ),
                                        hintText: 'eg. 123456',
                                        counterStyle: TextStyle(color: tribeColor.withOpacity(0.5) ?? Constants.inputCounterColor, fontFamily: 'TribesTrounded'),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(color: tribeColor.withOpacity(0.5) ?? Constants.inputEnabledColor, width: 2.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          borderSide: BorderSide(
                                            color: tribeColor ?? Constants.inputFocusColor, 
                                            width: 2.0
                                          ),
                                        )
                                      ),
                                      onChanged: (val) {
                                        setState(() => password = val);
                                      },
                                    ),
                                    SizedBox(height: Constants.smallSpacing),
                                    error.isNotEmpty
                                        ? Text(
                                            error,
                                            style: TextStyle(
                                                color: Constants.errorColor,
                                                fontSize:
                                                    Constants.errorFontSize),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ),
                            _buildDeleteTribeButton(currentTribe),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildSaveButton(currentTribe),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
