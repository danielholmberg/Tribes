import 'package:flutter/material.dart';
import 'package:tribes/services/auth.dart';
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
        elevation: Constants.appBarElevation,
        title: Text('Sign In'),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Register'),
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
                child: Text('Sign in', style: Theme.of(context).textTheme.button),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() => loading = true);
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    
                    if (result == null) {
                      setState(() { 
                        error = 'Unable to sign in with supplied credentials';
                        loading = false;
                      });
                    }
                  }
                },
              ),
              RaisedButton(
                child: Text('Sign In Anonymously', style: Theme.of(context).textTheme.button), 
                onPressed: () async {
                  dynamic result = await _auth.signInAnon();
                  if(result == null) {
                    print('ERROR signing in Anonymously');
                  } else {
                    print('Signed in Anonymously');
                    print(result.uid);
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