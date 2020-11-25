import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tribes/core/tribe/dialogs/tribe_settings_dialog.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

class TribeDetailsDialog extends StatefulWidget {
  final Tribe tribe;
  TribeDetailsDialog({@required this.tribe});

  @override
  _TribeDetailsDialogState createState() => _TribeDetailsDialogState();
}

class _TribeDetailsDialogState extends State<TribeDetailsDialog> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<MyUser> _membersList = [];
  List<MyUser> _searchResult = [];
  TextEditingController controller = new TextEditingController();
  Future membersFuture;
  bool loading = false;

  Tribe currentTribe;

  @override
  void initState() {
    currentTribe = widget.tribe;
    membersFuture = DatabaseService().tribeMembersList(currentTribe.members);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final MyUser currentUser = locator<DatabaseService>().currentUserData;
    print('Building TribesDetailsDialog()...');

    ThemeData themeData = Theme.of(context);

    bool isFounder = currentTribe != null ? currentUser.id == currentTribe.founder : false;
    
    _buildAppBar() {
      return AppBar(
        elevation: 0.0,
        backgroundColor: themeData.backgroundColor,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.times, color: currentTribe.color ?? themeData.primaryColor),
          splashColor: Colors.transparent,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tribe Details',
          style: TextStyle(
            color: currentTribe.color ?? themeData.primaryColor,
            fontFamily: 'TribesRounded',
            fontSize: Constants.defaultDialogTitleFontSize,
            fontWeight: Constants.defaultDialogTitleFontWeight
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Visibility(
            visible: isFounder,
            child: IconButton(
              icon: CustomAwesomeIcon(icon: FontAwesomeIcons.cog, color: currentTribe.color),
              splashColor: Colors.transparent,
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => TribeSettingsDialog(
                    tribe: currentTribe, 
                    onSave: (Tribe newTribe) => setState(() => currentTribe = newTribe),
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
                  Text('Chief', style: TextStyle(color: Colors.black54, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                  SizedBox(width: 12.0),
                  StreamBuilder<MyUser>(
                    stream: DatabaseService().userData(currentTribe.founder),
                    builder: (context, snapshot) {

                      if(snapshot.hasError) {
                        print('Error getting founder user data: ${snapshot.error.toString()}');
                      }

                      return UserAvatar(
                        currentUserID: currentUser.id,
                        user: snapshot.data, 
                        color: currentTribe.color,
                        radius: 12,
                        strokeWidth: 2.0,
                        strokeColor: Colors.white,
                        padding: const EdgeInsets.all(6.0),
                        withDecoration: true,
                        textPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                        textColor: Colors.white,
                      );
                      
                    }
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
                borderRadius: BorderRadius.circular(20.0)
              ),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Description', style: TextStyle(color: Colors.black54, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)), 
                    Text(
                      currentTribe.desc,
                      softWrap: true,
                      style: TextStyle(
                        color: currentTribe.color ?? themeData.primaryColor,
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
                Text('Password', style: TextStyle(color: Colors.black54, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                SizedBox(width: 8.0),
                Text(currentTribe.password, 
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
            if(isFounder) {
              showDialog(
                context: context,
                builder: (context) {
                  bool isDeleteButtonDisabled = true;

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                        backgroundColor: themeData.backgroundColor,
                        title: Text('Leaving Tribe', 
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
                                  text: 'As you are the Chief of this Tribe, this action will permanently ',
                                  style: TextStyle(
                                    color: Colors.black, 
                                    fontFamily: 'TribesRounded', 
                                    fontWeight: FontWeight.normal
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(text: 'DELETE', 
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: 'TribesRounded', 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    TextSpan(text: ' this Tribe and all its content. ', 
                                      style: TextStyle(
                                        fontFamily: 'TribesRounded', 
                                        fontWeight: FontWeight.normal
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\n\nPlease type ',
                                      style: TextStyle(
                                        fontFamily: 'TribesRounded',
                                        fontWeight: FontWeight.normal
                                      ),
                                    ),
                                    TextSpan(
                                      text: currentTribe.name,
                                      style: TextStyle(
                                        fontFamily: 'TribesRounded',
                                        fontWeight:FontWeight.bold
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' to delete this Tribe.',
                                      style: TextStyle(
                                        fontFamily: 'TribesRounded',
                                        fontWeight: FontWeight.normal
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextFormField(
                                textCapitalization: TextCapitalization.words,
                                cursorRadius: Radius.circular(1000),
                                decoration: Decorations.tribeDetailsInput.copyWith(
                                  hintText: currentTribe.name,
                                  labelStyle: TextStyle(
                                    color: currentTribe.color ?? Constants.inputLabelColor,
                                    fontFamily: 'TribesRounded',
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(color: currentTribe.color.withOpacity(0.5) ?? Constants.inputEnabledColor, width: 2.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                      color: currentTribe.color ?? Constants.inputFocusColor, 
                                      width: 2.0
                                    ),
                                  )
                                ),
                                onChanged: (val) {
                                  if (val == currentTribe.name) {
                                    setState(() => isDeleteButtonDisabled = false);
                                  } else {
                                    setState(() => isDeleteButtonDisabled = true);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Cancel', 
                              style: TextStyle(
                                fontFamily: 'TribesRounded', 
                                color: currentTribe.color ?? themeData.primaryColor,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // Dialog: "Please type..."
                            },
                          ),
                          FlatButton(
                            child: Text('Delete',
                              style: TextStyle(
                                fontFamily: 'TribesRounded', 
                                color: isDeleteButtonDisabled ? Colors.black54 : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: isDeleteButtonDisabled ? null
                            : () {
                              DatabaseService().deleteTribe(currentTribe.id);
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            },
                          ),
                        ],
                      );
                    }
                  );
                }
              );
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
                  backgroundColor: Constants
                      .profileSettingsBackgroundColor,
                  title: Text('Are your sure you want to leave this Tribe?', 
                    style: TextStyle(
                      fontFamily: 'TribesRounded', 
                      fontWeight: Constants.defaultDialogTitleFontWeight,
                      fontSize: Constants.defaultDialogTitleFontSize
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('No', 
                        style: TextStyle(
                          fontFamily: 'TribesRounded', 
                          color: currentTribe.color ?? themeData.primaryColor
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Yes',
                        style: TextStyle(
                          fontFamily: 'TribesRounded', 
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        DatabaseService().leaveTribe(currentUser.id, currentTribe.id);
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              );
            }
          } ,
          child: Text('Leave Tribe', 
            style: TextStyle(
              color: Colors.red,
              fontFamily: 'TribesRounded',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    _onSearchTextChanged(String text) async {
      _searchResult.clear();
      if (text.isEmpty) {
        setState(() {});
        return;
      }

      _membersList.forEach((friend) {
        if (friend.name.toLowerCase().contains(text.toLowerCase()) || 
        friend.username.toLowerCase().contains(text.toLowerCase())) {
          _searchResult.add(friend);
        }
      });

      setState(() {});
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
                Icon(FontAwesomeIcons.search, color: Colors.black54, size: Constants.smallIconSize),
              ],
            ),

            SizedBox(width: Constants.largePadding),

            // Center Widget
            Expanded(
              child: TextField(
                controller: controller,
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
                onChanged: _onSearchTextChanged,
              )
            ),

            // Trailing Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.solidTimesCircle,
                    color: controller.text.isEmpty ? Colors.grey : themeData.primaryColor,
                  ), 
                  onPressed: () {
                    controller.clear();
                    _onSearchTextChanged('');
                  },
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
          currentUserID: currentUser.id,
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
        future: membersFuture,
        builder: (context, snapshot) {

          if(snapshot.hasData) {
            _membersList = snapshot.data;

            final EdgeInsets listPadding = const EdgeInsets.symmetric(horizontal: 12.0);

            return Container(
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(), 
                child: _searchResult.length != 0 || controller.text.isNotEmpty
                ? ListView.builder(
                  padding: listPadding,
                  itemCount: _searchResult.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, i) {
                    return _friendTile(_searchResult[i]); 
                  }
                )
                : ListView.builder(
                  padding: listPadding,
                  itemCount: _membersList.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, i) {
                    return _friendTile(_membersList[i]);
                  },
                ),
              ),
            );
          } else if(snapshot.hasError){
            print('Error retrieving friends: ${snapshot.error.toString()}');
            return Center(child: Text('Unable to retrieve friends'));
          } else {
            return Center(child: Loading());
          }
        }
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
      contentPadding: EdgeInsets.zero,
      content: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          alignment: Alignment.topCenter,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: themeData.backgroundColor,
            appBar: _buildAppBar(),
            body: loading ? Loading(color: currentTribe.color) 
            : ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius)),
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
      ),
    );
  }
}