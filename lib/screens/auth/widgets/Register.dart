import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/services/auth.dart';
import 'package:tribes/shared/widgets/CustomRaisedButton.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/constants.dart' as Constants;

class Register extends StatefulWidget {

  final Function toggleView;
  
  Register({ this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final FocusNode nameFocus = new FocusNode();
  final FocusNode emailFocus = new FocusNode();
  final FocusNode passwordFocus = new FocusNode();
  final FocusNode registerButtonFocus = new FocusNode();
  bool loading = false;

  String name = '';
  String email = '';
  String password = '';
  String error = '';

  @override
  void dispose() {
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    registerButtonFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text('Register', 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0, 
                      fontFamily: 'TribesRounded', 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: Constants.defaultSpacing),
                    TextFormField(
                      focusNode: nameFocus,
                      cursorRadius: Radius.circular(1000),
                      textCapitalization: TextCapitalization.words,
                      decoration: Decorations.registerInput.copyWith(
                        hintText: 'Full name', 
                        prefixIcon: Icon(FontAwesomeIcons.solidUser, color: Constants.primaryColor)
                      ),
                      validator: (val) => val.isEmpty 
                        ? 'Enter your name' 
                        : null,
                      onChanged: (val) {
                        setState(() => name = val);
                      },
                      onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(emailFocus),
                    ),
                    SizedBox(height: Constants.defaultSpacing),
                    TextFormField(
                      focusNode: emailFocus,
                      cursorRadius: Radius.circular(1000),
                      keyboardType: TextInputType.emailAddress,
                      decoration: Decorations.registerInput.copyWith(
                        hintText: 'Email', 
                        prefixIcon: Icon(FontAwesomeIcons.at, color: Constants.primaryColor)
                      ),
                      validator: (val) => val.isEmpty 
                        ? 'Enter your email' 
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
                      decoration: Decorations.registerInput.copyWith(
                        hintText: 'Password', 
                        prefixIcon: Icon(FontAwesomeIcons.lock, color: Constants.primaryColor)
                      ),
                      validator: (val) => val.length < 6 
                        ? 'Enter a password with 6 characters or more' 
                        : null,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                      onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(registerButtonFocus),
                    ),
                    SizedBox(height: Constants.defaultSpacing),
                    Center(
                      child: GestureDetector(
                        onTap: () => widget.toggleView(),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(fontFamily: 'TribesRounded'),
                            children: <TextSpan>[
                              TextSpan(text: 'Sign In', 
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'TribesRounded', 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Constants.defaultSpacing),
                    ButtonTheme(
                      minWidth: MediaQuery.of(context).size.width,
                      height: 50.0,
                      child: CustomRaisedButton(
                        focusNode: registerButtonFocus,
                        text: 'Register',
                        inverse: true,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() => loading = true);
                            dynamic result = await _auth.registerWithEmailAndPassword(email, password, name);
                            if (result == null) {
                              setState(() { 
                                error = 'Please enter a valid email';
                                loading = false;
                              });
                            }
                          }
                        },
                      ),
                    ),
                    SizedBox(height: Constants.smallSpacing),
                    Text(
                      error,
                      style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: Constants.errorFontSize
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
