part of sign_in_view;

class _SignInViewMobile extends ViewModelWidget<SignInViewModel> {
  final AuthViewModel parentModel;
  _SignInViewMobile(this.parentModel);

  @override
  Widget build(BuildContext context, SignInViewModel model) {
    ThemeData themeData = Theme.of(context);

    _buildEmailSignInForm() {
      return Form(
        key: model.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: Constants.defaultSpacing),
            TextFormField(
              key: model.emailKey,
              focusNode: model.emailFocus,
              initialValue: model.email,
              cursorRadius: Radius.circular(1000),
              keyboardType: TextInputType.emailAddress,
              decoration: Decorations.signInInput.copyWith(
                hintText: 'Email',
                prefixIcon: Icon(
                  FontAwesomeIcons.at,
                  color: Constants.primaryColor,
                ),
              ),
              inputFormatters: model.inputFormatters,
              validator: model.emailValidator,
              onChanged: (val) => model.setEmail(val),
              onFieldSubmitted: model.onEmailSubmitted,
            ),
            SizedBox(height: Constants.defaultSpacing),
            TextFormField(
              key: model.passwordKey,
              focusNode: model.passwordFocus,
              cursorRadius: Radius.circular(1000),
              obscureText: true,
              decoration: Decorations.signInInput.copyWith(
                hintText: 'Password',
                prefixIcon: Icon(
                  FontAwesomeIcons.lock,
                  color: Constants.primaryColor,
                ),
              ),
              inputFormatters: model.inputFormatters,
              validator: model.passwordValidator,
              onChanged: (val) => model.setPassword(val),
              onFieldSubmitted: model.onPasswordSubmitted,
            ),
            SizedBox(height: Constants.defaultSpacing),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: model.onForgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'TribesRounded',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ).onlyDevelopment(false),
                GestureDetector(
                  onTap: () => parentModel.showRegisterView(),
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
              key: model.signInButtonKey,
              minWidth: MediaQuery.of(context).size.width,
              height: 50.0,
              child: CustomRaisedButton(
                focusNode: model.signInButtonFocus,
                text: 'Sign in with email',
                inverse: true,
                onPressed: () async {
                  await model.signInWithEmailAndPassword();
                  if (model.hasError) {
                    model.showErrorDialog();
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
            color: themeData.primaryColor,
          ),
          text: 'Use a Google account',
          inverse: true,
          onPressed: () async {
            await model.signInWithGoogle();
            if (model.hasError) {
              model.showErrorDialog();
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeData.primaryColor,
      resizeToAvoidBottomInset: !model.isBusy,
      body: Center(
        child: model.isBusy
            ? Loading(
                color: themeData.accentColor,
                size: 100,
              )
            : ScrollConfiguration(
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
                        Text(
                          'Or',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'TribesRounded',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                  ],
                ),
              ),
      ),
    );
  }
}
