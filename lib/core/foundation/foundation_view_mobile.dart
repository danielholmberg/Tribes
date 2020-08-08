part of foundation_view;

class _FoundationViewMobile extends StatelessWidget {
  final FoundationViewModel viewModel;
  _FoundationViewMobile(this.viewModel);

  @override
  Widget build(BuildContext context) {
    print('FoundationView');
    
    _showUnavailableUsernameDialog() {
      showDialog(
        context: context,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
          title: Text('Username already in use',
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
                Navigator.of(context).pop();
              },
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
                    style: DynamicTheme.of(context).data.textTheme.bodyText2,
                    children: <TextSpan>[
                      TextSpan(
                        text: viewModel.username,
                        style: DynamicTheme.of(context).data.textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' is already in use by a fellow Tribe explorer, please try another one.',
                        style: DynamicTheme.of(context).data.textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      );
    }

    _buildIntro() {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: DynamicTheme.of(context).data.primaryColor,
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
                    'Welcome ${viewModel.name}!', 
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    style: DynamicTheme.of(context).data.textTheme.headline6.copyWith(color: Colors.white, fontSize: 24),
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
                      style: DynamicTheme.of(context).data.textTheme.bodyText2.copyWith(color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'explore',
                          style: DynamicTheme.of(context).data.textTheme.bodyText2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: DynamicTheme.of(context).data.textTheme.bodyText2.copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'share',
                          style: DynamicTheme.of(context).data.textTheme.bodyText2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' your thoughts and dreams with your ',
                          style: DynamicTheme.of(context).data.textTheme.bodyText2.copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Tribes',
                          style: DynamicTheme.of(context).data.textTheme.bodyText2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' we first need you to enter your very own ',
                          style: DynamicTheme.of(context).data.textTheme.bodyText2.copyWith(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Username',
                          style: DynamicTheme.of(context).data.textTheme.bodyText2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Form(
                    key: viewModel.formKey,
                    child: TextFormField(
                    cursorRadius: Radius.circular(1000),
                    maxLength: Constants.profileUsernameMaxLength,
                    decoration: Decorations.registerInput.copyWith(
                      hintText: 'Username', 
                      prefixIcon: Icon(FontAwesomeIcons.userSecret, color: Constants.primaryColor)
                    ),
                    inputFormatters: [
                      new FilteringTextInputFormatter.deny(new RegExp('[\\ ]')),
                    ],
                    validator: (val) => val.toString().trim().isEmpty ? 'Oops, you need to enter a username' : null,
                    onChanged: (val) => viewModel.setUsername(val),
                    onFieldSubmitted: (val) => viewModel.onUsernameSubmitted(),
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
                        color: DynamicTheme.of(context).data.primaryColor,
                        size: 18,
                      ),
                      text: 'Submit',
                      inverse: true,
                      onPressed: () => viewModel.onUsernameSubmitted(),
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
        resizeToAvoidBottomInset: false,  // Avoid resize due to eg. toggled keyboard
        backgroundColor: DynamicTheme.of(context).data.backgroundColor,
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(), // Disable horizontal swipe
          controller: viewModel.tabController,
          children: viewModel.tabList,
        ),
        extendBody: true, // In order to show screen behind navigation bar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            color: DynamicTheme.of(context).data.primaryColor,
          ),
          child: CustomBottomNavBar(
            currentIndex: viewModel.currentTabIndex,
            backgroundColor: DynamicTheme.of(context).data.primaryColor,
            selectedItemColor: DynamicTheme.of(context).data.primaryColor,
            iconSize: 20.0,
            fontSize: 12.0,
            items: [
              CustomNavBarItem(icon: FontAwesomeIcons.home, title: 'Tribes'),
              CustomNavBarItem(icon: FontAwesomeIcons.mapMarkedAlt, title: 'Map'),
              CustomNavBarItem(icon: FontAwesomeIcons.solidComments, title: 'Chat'),
              CustomNavBarItem(icon: FontAwesomeIcons.solidUser, title: 'Profile'),
            ],
            onTap: (index) => viewModel.onTabTap(index),
          ),
        ),
      );
    }

    return viewModel.dataReady 
    ? (viewModel.currentUser.hasUsername() ? _buildFoundation() : _buildIntro())
    : Container(
      color: DynamicTheme.of(context).data.primaryColor,
      child: Center(
        child: Loading(color: DynamicTheme.of(context).data.accentColor)));
  }
}