import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomRaisedButton.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/constants.dart' as Constants;

class SignIn extends StatefulWidget {

  final Function toggleView;

  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final FocusNode emailFocus = new FocusNode();
  final FocusNode passwordFocus = new FocusNode();
  final FocusNode signInButtonFocus = new FocusNode();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    signInButtonFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _showErrorDialog() {
      showDialog(
        context: context,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
          title: Text('Sign in error',
            style: TextStyle(
              fontFamily: 'TribesRounded',
              fontWeight: Constants.defaultDialogTitleFontWeight,
              fontSize: Constants.defaultDialogTitleFontSize,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK', 
                style: TextStyle(
                  color: DynamicTheme.of(context).data.primaryColor,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                setState(() => error = '');
                Navigator.of(context).pop();
              },
            ),
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Text(
                  error, style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'TribesRounded', 
                    fontWeight: FontWeight.normal
                  ),
                ),
              ),
            ],
          ),
        )
      );
    }

    _buildEmailSignInForm() {
      return Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: Constants.defaultSpacing),
            TextFormField(
              focusNode: emailFocus,
              cursorRadius: Radius.circular(1000),
              keyboardType: TextInputType.emailAddress,
              decoration: Decorations.signInInput.copyWith(
                hintText: 'Email', 
                prefixIcon: Icon(FontAwesomeIcons.at, color: Constants.primaryColor)
              ),
              validator: (val) => val.isEmpty 
                ? 'Enter an email' 
                : null,
              onChanged: (val) {
                setState(() => email = val);
              },
              onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(passwordFocus),
            ),
            SizedBox(height: Constants.defaultSpacing),
            TextFormField(
              focusNode: passwordFocus,
              cursorRadius: Radius.circular(1000),
              obscureText: true,
              decoration: Decorations.signInInput.copyWith(
                hintText: 'Password', 
                prefixIcon: Icon(FontAwesomeIcons.lock, color: Constants.primaryColor)
              ),
              validator: (val) => val.length < 6 
                ? 'Enter a password with 6 characters or more' 
                : null,
              onChanged: (val) {
                setState(() => password = val);
              },
              onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(signInButtonFocus),
            ),
            SizedBox(height: Constants.defaultSpacing),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Fluttertoast.showToast(
                    msg: 'Coming soon!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  ),
                  child: Text(
                    'Forgot Password?', 
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'TribesRounded',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.toggleView(),
                  child: Text(
                    'Register', 
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'TribesRounded',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Constants.defaultSpacing),
            ButtonTheme(
              minWidth: MediaQuery.of(context).size.width,
              height: 50.0,
              child: CustomRaisedButton(
                focusNode: signInButtonFocus,
                text: 'Sign in with email',
                inverse: true,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() => loading = true);
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    
                    if (result == null) {
                      setState(() { 
                        error = 'Unable to sign in with supplied credentials';
                        loading = false;
                      });
                      _showErrorDialog();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

    _buildGoogleSignInButton() {
      return ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        height: 50.0,
        child: CustomRaisedButton(
          icon: CustomAwesomeIcon(
            icon: FontAwesomeIcons.google, 
            color: DynamicTheme.of(context).data.primaryColor,
          ),
          text: 'Use a Google account',
          inverse: true,
          onPressed: () async => await _auth.signInWithGoogle(),
        ),
      );
    }

    return loading ? Loading() : Scaffold(
      backgroundColor: DynamicTheme.of(context).data.primaryColor,
      body: Center(
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.all(50.0),
            children: <Widget>[
              Center(
                child: Text('Sign In', 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0, 
                    fontFamily: 'TribesRounded', 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildEmailSignInForm(),
              SizedBox(height: Constants.smallSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      indent: Constants.defaultSpacing,
                      endIndent: Constants.defaultSpacing,
                      color: Colors.white.withOpacity(0.6), 
                      thickness: 2.0,
                    ),
                  ),
                  Text('Or', style: TextStyle(color: Colors.white, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Divider(
                      indent: Constants.defaultSpacing,
                      endIndent: Constants.defaultSpacing,
                      color: Colors.white.withOpacity(0.6), 
                      thickness: 2.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Constants.smallSpacing),
              _buildGoogleSignInButton(),
            ]
          ),
        ),
      ),
    );
  }
}
