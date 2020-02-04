import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;

class TribeSettings extends StatefulWidget {
  final Tribe tribe;
  TribeSettings({this.tribe});

  @override
  _TribeSettingsState createState() => _TribeSettingsState();
}

class _TribeSettingsState extends State<TribeSettings> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

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

    _onPressDeleteButton() async {
      setState(() => loading = true);

      Navigator.of(context).popUntil((route) => route.isFirst);
      await DatabaseService().deleteTribe(widget.tribe.id);
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
                  ? Center(child: CircularProgressIndicator())
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
                                  ),
                                  SizedBox(height: Constants.defaultSpacing),
                                  TextFormField(
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
                                  SizedBox(height: Constants.defaultSpacing),
                                  ButtonTheme(
                                    height: 40.0,
                                    minWidth: MediaQuery.of(context).size.width,
                                    child: RaisedButton.icon(
                                      elevation: 8.0,
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
                                      label: Text('Change color'),
                                      textColor: Colors.white,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          child: AlertDialog(
                                            title: Text('Pick a Tribe color'),
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
                                  SizedBox(height: Constants.defaultSpacing),
                                  RaisedButton(
                                    color: DynamicTheme.of(context)
                                        .data
                                        .accentColor,
                                    child: Text('Save',
                                        style: DynamicTheme.of(context)
                                            .data
                                            .textTheme
                                            .button),
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        print('Updating Tribe information...');
                                        setState(() => loading = true);

                                        await DatabaseService().updateTribeData(
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
                                            imageURL);

                                        _scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text('Tribe info saved!'),
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
                                          backgroundColor: Constants
                                              .profileSettingsBackgroundColor,
                                          title: RichText(
                                            text: TextSpan(
                                              text: 'Please type ',
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontFamily: 'TribesRounded',
                                                  fontWeight:
                                                      FontWeight.normal),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: currentTribe.name,
                                                  style: TextStyle(
                                                      color: Colors.blueGrey,
                                                      fontFamily:
                                                          'TribesRounded',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text: ' to delete the Tribe.',
                                                  style: TextStyle(
                                                      color: Colors.blueGrey,
                                                      fontFamily:
                                                          'TribesRounded',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                          ),
                                          content: Container(
                                            child: TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              decoration: Decorations
                                                  .profileSettingsInput
                                                  .copyWith(
                                                hintText: 'Tribe name',
                                              ),
                                              onChanged: (val) {
                                                print(val);
                                                print(currentTribe.name);
                                                print(val == currentTribe.name);
                                                if (val == currentTribe.name) {
                                                  setState(() =>
                                                      isDeleteButtonDisabled =
                                                          false);
                                                } else {
                                                  setState(() =>
                                                      isDeleteButtonDisabled =
                                                          true);
                                                }
                                              },
                                            ),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Dialog: "Please type..."
                                              },
                                            ),
                                            FlatButton(
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: isDeleteButtonDisabled
                                                      ? Colors.black54
                                                      : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              onPressed: isDeleteButtonDisabled
                                                  ? null
                                                  : _onPressDeleteButton,
                                            ),
                                          ],
                                        );
                                      });
                                    });
                              },
                              child: Text(
                                'Delete Tribe',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
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
