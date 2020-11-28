part of new_tribe_view;

class _NewTribeViewMobile extends ViewModelWidget<NewTribeViewModel> {
  @override
  Widget build(BuildContext context, NewTribeViewModel model) {
    ThemeData themeData = Theme.of(context);

    _buildAppBar() {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.all(12.0),
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: model.tribeColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.black26, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Leading Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Platform.isIOS
                          ? FontAwesomeIcons.chevronLeft
                          : FontAwesomeIcons.arrowLeft,
                      color: Constants.buttonIconColor,
                    ),
                    onPressed: model.onBackPress,
                  ),
                ],
              ),

              SizedBox(width: Constants.defaultPadding),

              // Center Widget
              Expanded(
                child: Text(
                  'New Tribe',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'TribesRounded',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              // Trailing Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: CustomAwesomeIcon(
                      icon: model.isSecret
                          ? FontAwesomeIcons.solidEyeSlash
                          : FontAwesomeIcons.eye,
                      color: Constants.buttonIconColor
                          .withOpacity(model.isSecret ? 0.6 : 1.0),
                    ),
                    onPressed: model.onSecretPress,
                  ),
                  IconButton(
                    icon: CustomAwesomeIcon(
                      icon: FontAwesomeIcons.palette,
                      color: Constants.buttonIconColor,
                    ),
                    onPressed: model.onColorPick,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    _buildCreateButton() {
      return Visibility(
        visible: model.edited,
        child: CustomButton(
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(16.0),
          icon: FontAwesomeIcons.check,
          iconColor: Colors.white,
          color: Colors.green,
          label: Text(
            'Create',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'TribesRounded',
            ),
          ),
          labelColor: Colors.white,
          onPressed: model.onCreateTribe,
        ),
      );
    }

    return WillPopScope(
      onWillPop: model.onWillPop,
      child: Container(
        color: themeData.primaryColor,
        child: SafeArea(
          bottom: false,
          child: model.isBusy
              ? Loading(color: model.tribeColor)
              : Scaffold(
                  backgroundColor: themeData.backgroundColor,
                  body: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: ScrollConfiguration(
                          behavior: CustomScrollBehavior(),
                          child: ListView(
                            padding: EdgeInsets.only(top: 76, bottom: 36.0),
                            shrinkWrap: true,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topCenter,
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Form(
                                      key: model.formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          TextFormField(
                                            focusNode: model.nameFocus,
                                            cursorRadius: Radius.circular(1000),
                                            textCapitalization:
                                                TextCapitalization.words,
                                            maxLength:
                                                Constants.tribeNameMaxLength,
                                            cursorColor: model.tribeColor,
                                            decoration: Decorations
                                                .newTribeInput
                                                .copyWith(
                                                    labelText: 'Name',
                                                    labelStyle: TextStyle(
                                                      color: model.tribeColor,
                                                      fontFamily:
                                                          'TribesRounded',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    hintText: '',
                                                    counterStyle: TextStyle(
                                                      color: model.tribeColor
                                                          .withOpacity(0.5),
                                                      fontFamily:
                                                          'TribesRounded',
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                      borderSide: BorderSide(
                                                        color: model.tribeColor
                                                            .withOpacity(0.5),
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                      borderSide: BorderSide(
                                                        color: model.tribeColor,
                                                        width: 2.0,
                                                      ),
                                                    )),
                                            validator: model.nameValidator,
                                            onChanged: model.onNameChanged,
                                            onFieldSubmitted:
                                                model.onNameSubmitted,
                                          ),
                                          SizedBox(
                                              height: Constants.smallSpacing),
                                          TextFormField(
                                            focusNode: model.descFocus,
                                            cursorRadius: Radius.circular(1000),
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLength:
                                                Constants.tribeDescMaxLength,
                                            maxLines: null,
                                            decoration: Decorations
                                                .newTribeInput
                                                .copyWith(
                                              labelText: 'Description',
                                              labelStyle: TextStyle(
                                                color: model.tribeColor,
                                                fontFamily: 'TribesRounded',
                                                fontWeight: FontWeight.normal,
                                              ),
                                              hintText: '',
                                              counterStyle: TextStyle(
                                                color: model.tribeColor
                                                    .withOpacity(0.5),
                                                fontFamily: 'TribesRounded',
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                                borderSide: BorderSide(
                                                  color: model.tribeColor
                                                      .withOpacity(0.5),
                                                  width: 2.0,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                ),
                                                borderSide: BorderSide(
                                                  color: model.tribeColor,
                                                  width: 2.0,
                                                ),
                                              ),
                                            ),
                                            validator: model.descValidator,
                                            onChanged: model.onDescChanged,
                                          ),
                                          SizedBox(
                                            height: Constants.smallSpacing,
                                          ),
                                          Center(
                                            child: Text(
                                              model.currentError,
                                              style: TextStyle(
                                                color: Constants.errorColor,
                                                fontSize:
                                                    Constants.errorFontSize,
                                                fontFamily: 'TribesRounded',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildAppBar(),
                      Positioned(
                        bottom: Platform.isIOS ? 8.0 : 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: _buildCreateButton(),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
