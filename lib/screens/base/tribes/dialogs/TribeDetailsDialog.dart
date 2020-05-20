import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/screens/base/tribes/dialogs/TribeSettingsDialog.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/CustomAwesomeIcon.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';
import 'package:tribes/shared/widgets/UserAvatar.dart';

class TribeDetailsDialog extends StatefulWidget {
  final Tribe tribe;
  TribeDetailsDialog({@required this.tribe});

  @override
  _TribeDetailsDialogState createState() => _TribeDetailsDialogState();
}

class _TribeDetailsDialogState extends State<TribeDetailsDialog> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;

  Tribe currentTribe;

  @override
  void initState() {
    currentTribe = widget.tribe;
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building TribesDetailsDialog()...');

    bool isFounder = currentTribe != null ? currentUser.uid == currentTribe.founder : false;
    
    _buildAppBar() {
      return AppBar(
        elevation: 0.0,
        backgroundColor: DynamicTheme.of(context).data.backgroundColor,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.times, color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor),
          splashColor: Colors.transparent,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Tribe Details',
          style: TextStyle(
            color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
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
                  StreamBuilder<UserData>(
                    stream: DatabaseService().userData(currentTribe.founder),
                    builder: (context, snapshot) {

                      if(snapshot.hasError) {
                        print('Error getting founder user data: ${snapshot.error.toString()}');
                      }

                      return UserAvatar(
                        currentUserID: currentUser.uid, 
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
                        color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
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
                        backgroundColor: DynamicTheme.of(context).data.backgroundColor,
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
                                color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor,
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
                          color: currentTribe.color ?? DynamicTheme.of(context).data.primaryColor
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
                        DatabaseService().leaveTribe(currentUser.uid, currentTribe.id);
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
            backgroundColor: DynamicTheme.of(context).data.backgroundColor,
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