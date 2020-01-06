import 'package:flutter/material.dart';
import 'package:tribes/services/auth.dart';
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
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0.0,
        title: Text('Sign Up'),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Sign In'),
            onPressed: () {
              widget.toggleView();
            },
          ),
        ],
        iconTheme: Theme.of(context).iconTheme,
        textTheme: Theme.of(context).textTheme,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: Constants.defaultSpacing),
              TextFormField(
                decoration: Decorations.emailInputDecoration.copyWith(hintText: 'Email'),
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
                decoration: Decorations.passwordInputDecoration.copyWith(hintText: 'Password'),
                validator: (val) => val.length < 6 
                  ? 'Enter a password with 6 characters or more' 
                  : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              SizedBox(height: Constants.defaultSpacing),
              RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text('Register', style: Theme.of(context).textTheme.button),
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
      ),
    );
  }
}