import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:tribes/services/auth.dart';
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
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: DynamicTheme.of(context).data.primaryColor,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 50.0),
        child: Center(
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: ListView(
              shrinkWrap: true,
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
                        decoration: Decorations.registerInput.copyWith(
                          hintText: 'Email', 
                          prefixIcon: Icon(Icons.email, color: Constants.primaryColor)
                        ),
                        validator: (val) => val.isEmpty 
                          ? 'Enter an email' 
                          : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                      ),
                      SizedBox(height: Constants.defaultSpacing),
                      TextFormField(
                        obscureText: true,
                        decoration: Decorations.registerInput.copyWith(
                          hintText: 'Password', 
                          prefixIcon: Icon(Icons.lock, color: Constants.primaryColor)
                        ),
                        validator: (val) => val.length < 6 
                          ? 'Enter a password with 6 characters or more' 
                          : null,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
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
                        child: RaisedButton(
                          color: DynamicTheme.of(context).data.accentColor,
                          child: Text(
                            'Register',
                            style: DynamicTheme.of(context).data.textTheme.button
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() => loading = true);
                              dynamic result = await _auth.registerWithEmailAndPassword(email, password);
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
                          color: Constants.errorColor, 
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
      ),
    );
  }
}
