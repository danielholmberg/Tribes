import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/Loading.dart';

class TribeSettings extends StatefulWidget {
  final Tribe tribe;
  TribeSettings({this.tribe});

  @override
  _TribeSettingsState createState() => _TribeSettingsState();
}

class _TribeSettingsState extends State<TribeSettings> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode nameFocus = new FocusNode();
  final FocusNode descFocus = new FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  String name;
  String desc;
  Color tribeColor;
  String imageURL;
  String error = '';

  @override
  void dispose() {
    nameFocus.dispose();
    descFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      key: _scaffoldKey,
      body: StreamBuilder<Tribe>(
          stream: DatabaseService().tribe(widget.tribe.id),
          builder: (context, snapshot) {
            Tribe currentTribe =
                snapshot.hasData ? snapshot.data : widget.tribe;

            return SafeArea(
              child: loading
                  ? Loading()
                  : ScrollConfiguration(
                      behavior: CustomScrollBehavior(),
                      child: ListView(
                        padding: EdgeInsets.all(16.0),
                        shrinkWrap: true,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Tribe Settings',
                              style:
                                  DynamicTheme.of(context).data.textTheme.title,
                            ),
                          ),
                          Container(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: Constants.defaultSpacing),
                                  TextFormField(
                                    focusNode: nameFocus,
                                    initialValue: currentTribe.name,
                                    maxLength: Constants.tribeNameMaxLength,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: Decorations.profileSettingsInput
                                        .copyWith(
                                      labelText: 'Name',
                                    ),
                                    validator: (val) => val.isEmpty
                                        ? 'Please add a name'
                                        : null,
                                    onChanged: (val) {
                                      setState(() => name = val);
                                    },
                                    onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(descFocus),
                                  ),
                                  SizedBox(height: Constants.defaultSpacing),
                                  TextFormField(
                                    focusNode: descFocus,
                                    initialValue: currentTribe.desc,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.multiline,
                                    maxLength: Constants.tribeDescMaxLength,
                                    maxLines: null,
                                    decoration: Decorations.profileSettingsInput
                                        .copyWith(
                                      labelText: 'Description',
                                    ),
                                    onChanged: (val) {
                                      setState(() => desc = val);
                                    },
                                  ),
                                  SizedBox(height: Constants.smallSpacing),
                                  ButtonTheme(
                                    height: 40.0,
                                    minWidth: MediaQuery.of(context).size.width,
                                    child: RaisedButton.icon(
                                      elevation: Constants.defaultElevation,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      color: tribeColor != null
                                          ? tribeColor
                                          : currentTribe.color ??
                                              DynamicTheme.of(context)
                                                  .data
                                                  .primaryColor,
                                      icon: Icon(Icons.palette,
                                          color: DynamicTheme.of(context)
                                              .data
                                              .accentColor),
                                      label: Text('Change color',
                                        style: TextStyle(
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      textColor: Colors.white,
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
                                                availableColors: Constants
                                                    .defaultTribeColors,
                                                pickerColor: tribeColor ??
                                                    Constants.primaryColor,
                                                onColorChanged: _changeColor,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: Constants.smallSpacing),
                                  RaisedButton(
                                    color: DynamicTheme.of(context)
                                        .data
                                        .accentColor,
                                    child: Text('Save',
                                        style: DynamicTheme.of(context)
                                            .data
                                            .textTheme
                                            .button),
                                    onPressed: () {
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
                                          imageURL
                                        );

                                        _scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text('Tribe info saved',
                                            style: TextStyle(
                                              fontFamily: 'TribesRounded',
                                            ),
                                          ),
                                          duration: Duration(milliseconds: 500),
                                        ));

                                        setState(() => loading = false);
                                      }
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
                                  SizedBox(height: Constants.smallSpacing),
                                ],
                              ),
                            ),
                          ),
                          Align(
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
                                              textCapitalization: TextCapitalization.words,
                                              decoration: Decorations.profileSettingsInput.copyWith(
                                                hintText: currentTribe.name,
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
                          ),
                        ],
                      ),
                    ),
            );
          }),
    );
  }
}
