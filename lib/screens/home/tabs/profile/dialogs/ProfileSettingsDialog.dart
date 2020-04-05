import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/CustomRaisedButton.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/DiscardChangesDialog.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class ProfileSettingsDialog extends StatefulWidget {
  final UserData user;
  ProfileSettingsDialog({@required this.user});

  @override
  _ProfileSettingsDialogState createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final FocusNode nameFocus = new FocusNode();
  final FocusNode usernameFocus = new FocusNode();
  final FocusNode infoFocus = new FocusNode();
  final FocusNode saveButtonFocus = new FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  String name;
  String username;
  String info;
  String error = '';

  String originalName;
  String originalUsername;
  String originalInfo;

  @override
  void initState() { 
    originalName = widget.user.name;
    originalUsername = widget.user.username;
    originalInfo = widget.user.info;
    name = originalName;
    username = originalUsername;
    info = originalInfo;
    
    super.initState();
  }

  @override
  void dispose() {
    nameFocus.dispose();
    usernameFocus.dispose();
    infoFocus.dispose();
    saveButtonFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building ProfileSettings()...');
    print('Current user ${currentUser.toString()}');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
      contentPadding: EdgeInsets.zero,
      content: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.topCenter,
          child: currentUser == null ? Loading() 
          : Scaffold(
            key: _scaffoldKey,
            backgroundColor: DynamicTheme.of(context).data.backgroundColor,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: DynamicTheme.of(context).data.backgroundColor,
              leading: IconButton(
                icon: Icon(FontAwesomeIcons.times, color: DynamicTheme.of(context).data.primaryColor),
                onPressed: () {
                  bool edited = originalName != name || originalUsername != username || originalInfo != info;
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
                'Profile Settings',
                style: TextStyle(
                  color: DynamicTheme.of(context).data.primaryColor,
                  fontFamily: 'TribesRounded',
                  fontSize: Constants.defaultDialogTitleFontSize,
                  fontWeight: Constants.defaultDialogTitleFontWeight
                ),
              ),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(FontAwesomeIcons.signOutAlt, color: DynamicTheme.of(context).data.primaryColor), 
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                      backgroundColor: Constants
                          .profileSettingsBackgroundColor,
                      title: Text(
                        'Are your sure you want to sign out?',
                        style: TextStyle(
                          fontFamily: 'TribesRounded',
                          fontSize: Constants.defaultDialogTitleFontSize,
                          fontWeight: Constants.defaultDialogTitleFontWeight,
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: DynamicTheme.of(context).data.primaryColor,
                              fontFamily: 'TribesRounded',
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'TribesRounded',
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            _auth.signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: loading
              ? Loading()
              : ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[

                            // Name
                            TextFormField(
                              focusNode: nameFocus,
                              initialValue: name ?? widget.user.name,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              decoration: Decorations.profileSettingsInput.copyWith(
                                labelText: 'Name',
                                hintText: 'Full name'
                              ),
                              validator: (val) => val.isEmpty ? 'Please add your name' : null,
                              autovalidate: true,
                              onChanged: (val) {
                                setState(() => name = val);
                              },
                              onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(usernameFocus),
                            ),

                            SizedBox(height: Constants.defaultSpacing),

                            // Username
                            TextFormField(
                              focusNode: usernameFocus,
                              initialValue: username ?? widget.user.username,
                              maxLength: Constants.profileUsernameMaxLength,
                              textInputAction: TextInputAction.next,
                              decoration: Decorations.profileSettingsInput.copyWith(
                                labelText: 'Username',
                              ),
                              validator: (val) => val.isEmpty ? 'Your username cannot be empty' : null,
                              autovalidate: true,
                              autocorrect: false,
                              onChanged: (val) {
                                setState(() => username = val);
                              },
                              onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(infoFocus),
                            ),

                            SizedBox(height: Constants.smallSpacing),

                            // Info
                            TextFormField(
                              focusNode: infoFocus,
                              initialValue: info ?? widget.user.info,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              maxLength: Constants.profileInfoMaxLength,
                              maxLines: null,
                              decoration: Decorations.profileSettingsInput.copyWith(
                                labelText: 'Info',
                              ),
                              onChanged: (val) {
                                setState(() => info = val);
                              },
                              onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(saveButtonFocus),
                            ),

                            SizedBox(height: Constants.smallSpacing),

                            // Error message
                            error.isNotEmpty ? Text(
                              error,
                              style: TextStyle(
                                color: Constants.errorColor,
                                fontSize: Constants.errorFontSize
                              ),
                            ) : SizedBox.shrink(),
                            
                            // Save Button
                            CustomRaisedButton(
                              focusNode: saveButtonFocus,
                              text: 'Save',
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  print('Updating profile information...');
                                  setState(() => loading = true);

                                  await DatabaseService().updateUserData(
                                    currentUser.uid,
                                    name ?? currentUser.name,
                                    username ?? currentUser.username,
                                    currentUser.email,
                                    info ?? currentUser.info,
                                    currentUser.lat,
                                    currentUser.lng
                                  );

                                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: Text('Profile info saved'),
                                    duration: Duration(milliseconds: 500),
                                  ));

                                  setState(() {
                                    loading = false;
                                    originalName = name;
                                    originalUsername = username;
                                    originalInfo = info;
                                  });
                                }
                              },
                            ),

                          ],
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
