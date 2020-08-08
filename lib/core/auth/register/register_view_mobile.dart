part of register_view;

class _RegisterViewMobile extends ViewModelWidget<RegisterViewModel> {
  final AuthViewModel parentViewModel;
  _RegisterViewMobile(this.parentViewModel);

  @override
  Widget build(BuildContext context, RegisterViewModel viewModel) {
    return Scaffold(
      backgroundColor: DynamicTheme.of(context).data.primaryColor,
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
                key: viewModel.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: Constants.defaultSpacing),
                    TextFormField(
                      focusNode: viewModel.nameFocus,
                      cursorRadius: Radius.circular(1000),
                      textCapitalization: TextCapitalization.words,
                      decoration: Decorations.registerInput.copyWith(
                        hintText: 'Full name', 
                        prefixIcon: Icon(FontAwesomeIcons.solidUser, color: Constants.primaryColor)
                      ),
                      validator: (val) => val.toString().trim().isEmpty 
                        ? 'Oops, you forgot to enter your name' 
                        : null,
                      onChanged: (val) => viewModel.setName(val),
                      onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(viewModel.emailFocus),
                    ),
                    SizedBox(height: Constants.defaultSpacing),
                    TextFormField(
                      focusNode: viewModel.emailFocus,
                      cursorRadius: Radius.circular(1000),
                      keyboardType: TextInputType.emailAddress,
                      decoration: Decorations.registerInput.copyWith(
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
                      decoration: Decorations.registerInput.copyWith(
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
                      onFieldSubmitted: (val) => FocusScope.of(context).requestFocus(viewModel.registerButtonFocus),
                    ),
                    SizedBox(height: Constants.defaultSpacing),
                    Center(
                      child: GestureDetector(
                        onTap: () => parentViewModel.showSignInView(),
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
                        focusNode: viewModel.registerButtonFocus,
                        text: 'Register',
                        inverse: true,
                        onPressed: () async => viewModel.registerWithEmailAndPassword(),
                      ),
                    ),
                    SizedBox(height: Constants.smallSpacing),
                    Text(
                      viewModel.error,
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