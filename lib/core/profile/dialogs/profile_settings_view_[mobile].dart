part of profile_settings_view;

class _ProfileSettingsViewMobile extends ViewModelWidget<ProfileSettingsViewModel> {
  @override
  Widget build(BuildContext context, ProfileSettingsViewModel model) {
    ThemeData themeData = Theme.of(context);

    _buildAppBar() {
      return AppBar(
        elevation: 0.0,
        backgroundColor: themeData.backgroundColor,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.times, color: themeData.primaryColor),
          onPressed: () {
            if(model.edited) {
              showDialog(
                context: context,
                builder: (context) => DiscardChangesDialog()
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Profile Settings',
          style: TextStyle(
            color: themeData.primaryColor,
            fontFamily: 'TribesRounded',
            fontSize: Constants.defaultDialogTitleFontSize,
            fontWeight: Constants.defaultDialogTitleFontWeight
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.signOutAlt, color: themeData.primaryColor),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                backgroundColor: Constants
                    .profileSettingsBackgroundColor,
                title: Text(
                  'Are your sure you want to sign out?',
                  style: TextStyle(
                    fontFamily: 'TribesRounded',
                    fontSize: Constants.defaultDialogTitleFontSize,
                    fontWeight: Constants.defaultDialogTitleFontWeight,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'No',
                      style: TextStyle(
                        color: themeData.primaryColor,
                        fontFamily: 'TribesRounded',
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TribesRounded',
                      ),
                    ),
                    onPressed: model.onSignOutConfirmed,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    _buildSaveButton() {
      return Visibility(
        visible: model.edited,
        child: CustomButton(
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(16.0),
          color: Colors.green,
          icon: FontAwesomeIcons.check,
          label: Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'TribesRounded')),
          labelColor: Colors.white,
          onPressed: model.onSaveSettings,
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
      contentPadding: EdgeInsets.zero,
      content: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * (model.edited ? 0.6 : 0.5),
          alignment: Alignment.topCenter,
          child: Scaffold(
            backgroundColor: themeData.backgroundColor,
            appBar: _buildAppBar(),
            body: SafeArea(
              child: model.isBusy
              ? Loading()
              : ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ListView(
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, (model.edited ? 86.0 : 16.0)),
                        shrinkWrap: true,
                        children: <Widget>[
                          Container(
                            child: Form(
                              key: model.formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[

                                  // Name
                                  TextFormField(
                                    focusNode: model.nameFocus,
                                    cursorRadius: Radius.circular(1000),
                                    initialValue: model.initialName,
                                    textCapitalization: TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    decoration: Decorations.profileSettingsInput.copyWith(
                                      labelText: 'Name',
                                      hintText: 'Full name'
                                    ),
                                    validator: model.nameValidator,
                                    autovalidateMode: AutovalidateMode.always,
                                    onChanged: model.onNameChanged,
                                    onFieldSubmitted: model.onNameSubmitted,
                                  ),

                                  SizedBox(height: Constants.defaultSpacing),

                                  // Username
                                  TextFormField(
                                    focusNode: model.usernameFocus,
                                    cursorRadius: Radius.circular(1000),
                                    initialValue: model.initalUsername,
                                    maxLength: Constants.profileUsernameMaxLength,
                                    textInputAction: TextInputAction.done,
                                    decoration: Decorations.profileSettingsInput.copyWith(
                                      labelText: 'Username',
                                    ),
                                    inputFormatters: model.inputFormatters,
                                    validator: model.usernameValidator,
                                    onChanged: model.onUsernameChanged,
                                    onFieldSubmitted: model.onUsernameSubmitted,
                                  ),

                                  SizedBox(height: Constants.smallSpacing),

                                  // Info
                                  TextFormField(
                                    focusNode: model.infoFocus,
                                    cursorRadius: Radius.circular(1000),
                                    initialValue: model.initialInfo,
                                    textCapitalization: TextCapitalization.sentences,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                    maxLength: Constants.profileInfoMaxLength,
                                    maxLines: null,
                                    decoration: Decorations.profileSettingsInput.copyWith(
                                      labelText: 'Info',
                                    ),
                                    onChanged: model.onInfoChanged,
                                    onFieldSubmitted: model.onInfoSubmitted,
                                  ),

                                  SizedBox(height: Constants.smallSpacing),

                                  // Error message
                                  Visibility(
                                    visible: model.hasError,
                                    child: Text(
                                      model.currentError,
                                      style: TextStyle(
                                        color: Constants.errorColor,
                                        fontSize: Constants.errorFontSize
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildSaveButton(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
