import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';

class ProfileSettings extends StatefulWidget {
  final UserData user;
  ProfileSettings({this.user});

  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  String name;
  String username;
  String info;
  String error = '';

  @override
  Widget build(BuildContext context) {
    print('Building ProfileSettings()...');
    print('Current user ${widget.user.toString()}');

    return Scaffold(
      key: _scaffoldKey,
      body: StreamBuilder<UserData>(
          stream: DatabaseService().currentUser(widget.user.uid),
          builder: (context, snapshot) {
            UserData currentUser =
                snapshot.hasData ? snapshot.data : widget.user;

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
                              'Profile Settings',
                              style:
                                  DynamicTheme.of(context).data.textTheme.title,
                            ),
                          ),
                          Container(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: Constants.defaultSpacing),
                                  TextFormField(
                                    initialValue: currentUser.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: Decorations.profileSettingsInput
                                        .copyWith(
                                      labelText: 'Name',
                                    ),
                                    validator: (val) => val.isEmpty
                                        ? 'Please add your name'
                                        : null,
                                    autovalidate: true,
                                    onChanged: (val) {
                                      setState(() => name = val);
                                    },
                                  ),
                                  SizedBox(height: Constants.defaultSpacing),
                                  TextFormField(
                                    initialValue: currentUser.username,
                                    maxLength: Constants.profileUsernameMaxLength,
                                    decoration: Decorations.profileSettingsInput
                                        .copyWith(
                                      labelText: 'Username',
                                    ),
                                    validator: (val) => val.isEmpty
                                        ? 'Your username cannot be empty'
                                        : null,
                                    autovalidate: true,
                                    onChanged: (val) {
                                      setState(() => username = val);
                                    },
                                  ),
                                  SizedBox(height: Constants.defaultSpacing),
                                  TextFormField(
                                    initialValue: currentUser.info,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.multiline,
                                    maxLength: Constants.profileInfoMaxLength,
                                    maxLines: null,
                                    decoration: Decorations.profileSettingsInput
                                        .copyWith(
                                      labelText: 'Info',
                                    ),
                                    onChanged: (val) {
                                      setState(() => info = val);
                                    },
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
                                        print(
                                            'Updating profile information...');
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

                                        _scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text('Profile info saved'),
                                          duration: Duration(milliseconds: 500),
                                        ));

                                        setState(() => loading = false);
                                      }
                                    },
                                  ),
                                  SizedBox(height: Constants.smallSpacing),
                                  error.isNotEmpty ? Text(
                                    error,
                                    style: TextStyle(
                                        color: Constants.errorColor,
                                        fontSize: Constants.errorFontSize),
                                  ) : SizedBox.shrink(),
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
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                                    backgroundColor: Constants
                                        .profileSettingsBackgroundColor,
                                    title: Text('Are your sure you want to sign out?',
                                      style: TextStyle(
                                        fontFamily: 'TribesRounded',
                                        fontSize: Constants.defaultDialogTitleFontSize,
                                        fontWeight: Constants.defaultDialogTitleFontWeight,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('No',
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
                                        child: Text('Yes',
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
                                );
                              },
                              child: Text(
                                'Sign out',
                                style: TextStyle(
                                  fontFamily: 'TribesRounded',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(height: Constants.largePadding),
                        ],
                      ),
                    ),
            );
          }),
    );
  }
}
