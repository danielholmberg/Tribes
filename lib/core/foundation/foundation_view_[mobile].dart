part of foundation_view;

class _FoundationViewMobile extends ViewModelWidget<FoundationViewModel> {
  _FoundationViewMobile();

  @override
  Widget build(BuildContext context, FoundationViewModel model) {
    ThemeData themeData = Theme.of(context);

    _showUnavailableUsernameDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(Constants.dialogCornerRadius),
            ),
          ),
          title: Text(
            'Username already in use',
            style: TextStyle(
              fontFamily: 'TribesRounded',
              fontWeight: Constants.defaultDialogTitleFontWeight,
              fontSize: Constants.defaultDialogTitleFontSize,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: themeData.primaryColor,
                  fontFamily: 'TribesRounded',
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: model.back,
            ),
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: RichText(
                  maxLines: null,
                  softWrap: true,
                  text: TextSpan(
                    text: 'The username ',
                    style: themeData.textTheme.bodyText2,
                    children: <TextSpan>[
                      TextSpan(
                        text: model.username,
                        style: themeData.textTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' is already in use by a fellow Tribe explorer, please try another one.',
                        style: themeData.textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    _buildIntro() {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: themeData.primaryColor,
        body: Center(
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: ListView(
              physics: ClampingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Welcome ${model.name}!',
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    style: themeData.textTheme.headline6.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RichText(
                    maxLines: null,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Before you can begin to ',
                      style: themeData.textTheme.bodyText2
                          .copyWith(color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'explore',
                          style: themeData.textTheme.bodyText2.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: themeData.textTheme.bodyText2
                              .copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'share',
                          style: themeData.textTheme.bodyText2.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' your thoughts and dreams with your ',
                          style: themeData.textTheme.bodyText2
                              .copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Tribes',
                          style: themeData.textTheme.bodyText2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' we first need you to enter your very own ',
                          style: themeData.textTheme.bodyText2
                              .copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Username',
                          style: themeData.textTheme.bodyText2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Form(
                  key: model.formKey,
                  child: TextFormField(
                    cursorRadius: Radius.circular(1000),
                    maxLength: Constants.profileUsernameMaxLength,
                    decoration: Decorations.registerInput.copyWith(
                      hintText: 'Username',
                      prefixIcon: Icon(
                        FontAwesomeIcons.userSecret,
                        color: Constants.primaryColor,
                      ),
                    ),
                    inputFormatters: model.inputFormatters,
                    validator: model.usernameValidator,
                    onChanged: (val) => model.onUsernameChanged(val),
                    onFieldSubmitted: (String value) async {
                      await model.onUsernameSubmitted(value);

                      if (!model.usernameAlreadyInUse) {
                        _showUnavailableUsernameDialog();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 50.0,
                    child: CustomRaisedButton(
                      icon: CustomAwesomeIcon(
                        icon: FontAwesomeIcons.check,
                        color: themeData.primaryColor,
                        size: 18,
                      ),
                      text: 'Submit',
                      inverse: true,
                      onPressed: () async {
                        await model.onUsernameSubmitted(model.username);

                        if (!model.usernameAlreadyInUse) {
                          _showUnavailableUsernameDialog();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _buildFoundation() {
      return Scaffold(
        resizeToAvoidBottomInset:
            false, // Avoid resize due to eg. toggled keyboard
        backgroundColor: themeData.backgroundColor,
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(), // Disable horizontal swipe
          controller: model.tabController,
          children: model.tabList,
        ),
        extendBody: true, // In order to show screen behind navigation bar
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: model.currentTabIndex,
          backgroundColor: themeData.primaryColor,
          selectedItemColor: themeData.primaryColor,
          iconSize: 20.0,
          fontSize: 12.0,
          items: [
            CustomNavBarItem(
              icon: FontAwesomeIcons.home,
              title: 'Tribes',
            ),
            CustomNavBarItem(
              icon: FontAwesomeIcons.mapMarkedAlt,
              title: 'Map',
            ),
            CustomNavBarItem(
              icon: FontAwesomeIcons.solidComments,
              title: 'Chat',
            ),
            CustomNavBarItem(
              icon: FontAwesomeIcons.solidUser,
              title: 'Profile',
              avatar: UserAvatar(
                currentUserID: model.currentUser.id,
                user: model.currentUser,
                radius: 12,
                color: themeData.backgroundColor,
                strokeWidth: 1.0,
                onlyAvatar: true,
                disable: true,
              ),
            ),
          ],
          onTap: model.onTabTap,
        ),
      );
    }

    return model.currentUser != null
        ? (model.currentUserHasUsername ? _buildFoundation() : _buildIntro())
        : Container(
            color: themeData.primaryColor,
            child: Center(
              child: Loading(
                color: themeData.accentColor,
              ),
            ),
          );
  }
}
