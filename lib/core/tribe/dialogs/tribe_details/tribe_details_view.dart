import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/tribe/dialogs/tribe_details/tribe_details_view_model.dart';
import 'package:tribes/core/tribe/dialogs/tribe_settings/tribe_settings_view.dart';
import 'package:tribes/core/tribe/dialogs/tribe_settings/tribe_settings_view_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

class TribeDetailsView extends ViewModelWidget<TribeDetailsViewModel> {
  @override
  Widget build(BuildContext context, TribeDetailsViewModel model) {
    final ThemeData themeData = Theme.of(context);

    _buildAppBar() {
      return AppBar(
        elevation: 0.0,
        backgroundColor: themeData.backgroundColor,
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.times,
            color: model.currentTribeColor,
          ),
          splashColor: Colors.transparent,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tribe Details',
          style: TextStyle(
            color: model.currentTribeColor,
            fontFamily: 'TribesRounded',
            fontSize: Constants.defaultDialogTitleFontSize,
            fontWeight: Constants.defaultDialogTitleFontWeight,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Visibility(
            visible: model.isFounder,
            child: IconButton(
              icon: CustomAwesomeIcon(
                icon: FontAwesomeIcons.cog,
                color: model.currentTribeColor,
              ),
              splashColor: Colors.transparent,
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(Constants.dialogCornerRadius),
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    content: ViewModelBuilder<TribeSettingsViewModel>.reactive(
                      viewModelBuilder: () => TribeSettingsViewModel(onSave: model.onSaveUpdatedTribe),
                      onModelReady: (_model) => _model.initState(
                        context: context,
                        tribe: model.currentTribe,
                      ),
                      builder: (context, _model, child) {
                        return TribeSettingsView();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: Constants.defaultPadding),
        ],
      );
    }

    _buildChief() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    'Chief',
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'TribesRounded',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 12.0),
                  StreamBuilder<MyUser>(
                    stream: model.tribeFounderStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print(
                            'Error getting founder user data: ${snapshot.error.toString()}');
                      }

                      return UserAvatar(
                        currentUserID: model.currentUser.id,
                        user: snapshot.data,
                        color: model.currentTribeColor,
                        radius: 12,
                        strokeWidth: 2.0,
                        strokeColor: Colors.white,
                        padding: const EdgeInsets.all(6.0),
                        withDecoration: true,
                        textPadding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 6.0,
                        ),
                        textColor: Colors.white,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    _buildDescription() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Description',
                        style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'TribesRounded',
                            fontWeight: FontWeight.bold)),
                    Text(
                      model.currentTribe.desc,
                      softWrap: true,
                      style: TextStyle(
                        color: model.currentTribeColor,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'TribesRounded',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    _buildPassword() {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Password',
                  style: TextStyle(
                    color: Colors.black54,
                    fontFamily: 'TribesRounded',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  model.currentTribe.password,
                  style: TextStyle(
                    fontFamily: 'TribesRounded',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    letterSpacing: 6.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    _buildLeaveTribeButton() {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            if (model.isFounder) {
              showDialog(
                  context: context,
                  builder: (context) {
                    bool isDeleteButtonDisabled = true;

                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(Constants.dialogCornerRadius),
                          ),
                        ),
                        backgroundColor: themeData.backgroundColor,
                        title: Text(
                          'Leaving Tribe',
                          style: TextStyle(
                            fontFamily: 'TribesRounded',
                            fontWeight: Constants.defaultDialogTitleFontWeight,
                            fontSize: Constants.defaultDialogTitleFontSize,
                          ),
                        ),
                        content: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              RichText(
                                text: TextSpan(
                                  text:
                                      'As you are the Chief of this Tribe, this action will permanently ',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'TribesRounded',
                                      fontWeight: FontWeight.normal),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'DELETE',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: ' this Tribe and all its content. ',
                                      style: TextStyle(
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.normal),
                                    ),
                                    TextSpan(
                                      text: '\n\nPlease type ',
                                      style: TextStyle(
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.normal),
                                    ),
                                    TextSpan(
                                      text: model.currentTribe.name,
                                      style: TextStyle(
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: ' to delete this Tribe.',
                                      style: TextStyle(
                                          fontFamily: 'TribesRounded',
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              TextFormField(
                                textCapitalization: TextCapitalization.words,
                                cursorRadius: Radius.circular(1000),
                                decoration:
                                    Decorations.tribeDetailsInput.copyWith(
                                  hintText: model.currentTribe.name,
                                  labelStyle: TextStyle(
                                    color: model.currentTribeColor,
                                    fontFamily: 'TribesRounded',
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: model.currentTribeColor
                                          .withOpacity(0.5),
                                      width: 2.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    borderSide: BorderSide(
                                      color: model.currentTribeColor,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                onChanged: (String value) {
                                  if (value == model.currentTribe.name) {
                                    setState(
                                        () => isDeleteButtonDisabled = false);
                                  } else {
                                    setState(
                                        () => isDeleteButtonDisabled = true);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'TribesRounded',
                                color: model.currentTribeColor,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Dialog: "Please type..."
                            },
                          ),
                          FlatButton(
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                fontFamily: 'TribesRounded',
                                color: isDeleteButtonDisabled
                                    ? Colors.black54
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: isDeleteButtonDisabled
                                ? null
                                : model.onDeleteTribe,
                          ),
                        ],
                      );
                    });
                  });
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(Constants.dialogCornerRadius))),
                  backgroundColor: Constants.profileSettingsBackgroundColor,
                  title: Text(
                    'Are your sure you want to leave this Tribe?',
                    style: TextStyle(
                        fontFamily: 'TribesRounded',
                        fontWeight: Constants.defaultDialogTitleFontWeight,
                        fontSize: Constants.defaultDialogTitleFontSize),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                        'No',
                        style: TextStyle(
                          fontFamily: 'TribesRounded',
                          color: model.currentTribeColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          fontFamily: 'TribesRounded',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: model.onLeaveTribe,
                    ),
                  ],
                ),
              );
            }
          },
          child: Text(
            'Leave Tribe',
            style: TextStyle(
              color: Colors.red,
              fontFamily: 'TribesRounded',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    _buildSearchField() {
      return Container(
        margin: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.black54, width: 2.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: Constants.largePadding),

            // Leading Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(FontAwesomeIcons.search,
                    color: Colors.black54, size: Constants.smallIconSize),
              ],
            ),

            SizedBox(width: Constants.largePadding),

            // Center Widget
            Expanded(
                child: TextField(
              controller: model.controller,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Find tribe member',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontFamily: 'TribesRounded',
                  fontSize: 16,
                  color: Colors.black54.withOpacity(0.3),
                ),
              ),
              onChanged: model.onSearchTextChanged,
            )),

            // Trailing Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.solidTimesCircle,
                    color: model.controller.text.isEmpty
                        ? Colors.grey
                        : themeData.primaryColor,
                  ),
                  onPressed: model.onSearchTextClearPress,
                ),
              ],
            ),
          ],
        ),
      );
    }

    _friendTile(MyUser friend) {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        leading: UserAvatar(
          currentUserID: model.currentUser.id,
          user: friend,
          radius: 20,
          withName: true,
          withUsername: true,
          cornerRadius: 0.0,
          color: themeData.primaryColor,
          textColor: themeData.primaryColor,
          textPadding: const EdgeInsets.only(left: 8.0),
        ),
      );
    }

    _buildTribeMembers() {
      return FutureBuilder<List<MyUser>>(
        future: model.membersFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            model.setMembersList(snapshot.data);

            final EdgeInsets listPadding =
                const EdgeInsets.symmetric(horizontal: 12.0);

            return Container(
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: model.searchResultCount != 0 ||
                        model.controller.text.isNotEmpty
                    ? ListView.builder(
                        padding: listPadding,
                        itemCount: model.searchResultCount,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _friendTile(model.getUserFromSearch(index));
                        })
                    : ListView.builder(
                        padding: listPadding,
                        itemCount: model.membersCount,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _friendTile(model.getUserFromMembers(index));
                        },
                      ),
              ),
            );
          } else if (snapshot.hasError) {
            print('Error retrieving friends: ${snapshot.error.toString()}');
            return Center(child: Text('Unable to retrieve friends'));
          } else {
            return Center(child: Loading());
          }
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        alignment: Alignment.topCenter,
        child: Scaffold(
          backgroundColor: themeData.backgroundColor,
          appBar: _buildAppBar(),
          body: model.isBusy
              ? Loading(color: model.currentTribeColor)
              : ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(Constants.dialogCornerRadius),
                    ),
                    child: ListView(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                      children: <Widget>[
                        _buildChief(),
                        _buildDescription(),
                        _buildPassword(),
                        _buildLeaveTribeButton(),
                        _buildSearchField(),
                        _buildTribeMembers(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
