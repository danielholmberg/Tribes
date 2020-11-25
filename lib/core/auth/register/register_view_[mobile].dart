part of register_view;

class _RegisterViewMobile extends ViewModelWidget<RegisterViewModel> {
  final AuthViewModel parentModel;
  _RegisterViewMobile(this.parentModel);

  @override
  Widget build(BuildContext context, RegisterViewModel model) {
    ThemeData themeData = Theme.of(context);

    _buildRegisterForm() {
      return Form(
        key: model.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: Constants.defaultSpacing),
            TextFormField(
              focusNode: model.nameFocus,
              cursorRadius: Radius.circular(1000),
              textCapitalization: TextCapitalization.words,
              decoration: Decorations.registerInput.copyWith(
                hintText: 'Full name',
                prefixIcon: Icon(
                  FontAwesomeIcons.solidUser,
                  color: Constants.primaryColor,
                ),
              ),
              validator: model.nameValidator,
              onChanged: (val) => model.setName(val),
              onFieldSubmitted: model.onNameSubmitted,
            ),
            SizedBox(height: Constants.defaultSpacing),
            TextFormField(
              focusNode: model.emailFocus,
              cursorRadius: Radius.circular(1000),
              keyboardType: TextInputType.emailAddress,
              decoration: Decorations.registerInput.copyWith(
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
              focusNode: model.passwordFocus,
              cursorRadius: Radius.circular(1000),
              obscureText: true,
              decoration: Decorations.registerInput.copyWith(
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
            Center(
              child: GestureDetector(
                onTap: () => parentModel.showSignInView(),
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(fontFamily: 'TribesRounded'),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'TribesRounded',
                          fontWeight: FontWeight.bold,
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
                focusNode: model.registerButtonFocus,
                text: 'Register',
                inverse: true,
                onPressed: () async =>
                    await model.registerWithEmailAndPassword(),
              ),
            ),
            SizedBox(height: Constants.smallSpacing),
            Text(
              model.currentError,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: Constants.errorFontSize,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeData.primaryColor,
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
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontFamily: 'TribesRounded',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildRegisterForm(),
                  ],
                ),
              ),
      ),
    );
  }
}
