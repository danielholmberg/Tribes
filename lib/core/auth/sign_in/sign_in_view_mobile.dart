part of sign_in_view;

class _SignInViewMobile extends ViewModelWidget<SignInViewModel> {
  final AuthViewModel parentViewModel;
  _SignInViewMobile(this.parentViewModel);

  @override
  Widget build(BuildContext context, SignInViewModel viewModel) {
    
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
                viewModel.setError('');
                Navigator.of(context).pop();
              },
            ),
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Text(
                  viewModel.error, style: TextStyle(
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
        key: viewModel.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: Constants.defaultSpacing),
            TextFormField(
              focusNode: viewModel.emailFocus,
              initialValue: viewModel.email,
              cursorRadius: Radius.circular(1000),
              keyboardType: TextInputType.emailAddress,
              decoration: Decorations.signInInput.copyWith(
                hintText: 'Email', 
                prefixIcon: Icon(FontAwesomeIcons.at, color: Constants.primaryColor)
              ),
              inputFormatters: [
                new FilteringTextInputFormatter.deny(new RegExp('[\\ ]')),
              ],
              validator: (val) => val.toString().trim().isEmpty 
                ? 'Oops, you forgot to enter your email' 
                : null,
              onChanged: (val) => viewModel.setEmail(val),
              onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(viewModel.passwordFocus),
            ),
            SizedBox(height: Constants.defaultSpacing),
            TextFormField(
              focusNode: viewModel.passwordFocus,
              cursorRadius: Radius.circular(1000),
              obscureText: true,
              decoration: Decorations.signInInput.copyWith(
                hintText: 'Password', 
                prefixIcon: Icon(FontAwesomeIcons.lock, color: Constants.primaryColor)
              ),
              inputFormatters: [
                new FilteringTextInputFormatter.deny(new RegExp('[\\ ]')),
              ],
              validator: (val) => val.trim().isEmpty || val.length < 6 
                ? 'Password must be 6 characters or more' 
                : null,
              onChanged: (val) => viewModel.setPassword(val),
              onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(viewModel.signInButtonFocus),
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
                  onTap: () => parentViewModel.showRegisterView(),
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
                focusNode: viewModel.signInButtonFocus,
                text: 'Sign in with email',
                inverse: true,
                onPressed: () async {
                  await viewModel.signInWithEmailAndPassword();
                  if(viewModel.showErrorDialog) {
                    _showErrorDialog();
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
          onPressed: () async {
            await viewModel.signInWithGoogle();
            if(viewModel.showErrorDialog) {
              _showErrorDialog();
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: DynamicTheme.of(context).data.primaryColor,
      resizeToAvoidBottomInset: !viewModel.isBusy,
      body: Center(
        child: viewModel.isBusy ? Loading(
        color: DynamicTheme.of(context).data.accentColor,
        size: 100,
      ) : ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(50.0),
              children: <Widget>[
                Center(
                  child: Text(
                    'Sign In',
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
                    Text('Or',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'TribesRounded',
                            fontWeight: FontWeight.bold)),
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
              ]),
        ),
      ),
    );
  }
}
