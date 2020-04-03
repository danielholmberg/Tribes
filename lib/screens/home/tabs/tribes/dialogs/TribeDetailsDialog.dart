import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
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
  
  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building TribesDetailsDialog()...');
    print('Current user ${currentUser.toString()}');

    bool isFounder = widget.tribe != null ? currentUser.uid == widget.tribe.founder : false;
    
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
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: DynamicTheme.of(context).data.backgroundColor,
              leading: IconButton(
                icon: Icon(FontAwesomeIcons.times, color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Tribe Details',
                style: TextStyle(
                  color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                  fontFamily: 'TribesRounded',
                  fontSize: Constants.defaultDialogTitleFontSize,
                  fontWeight: Constants.defaultDialogTitleFontWeight
                ),
              ),
              centerTitle: true,
            ),
            body: loading ? Loading(color: widget.tribe.color) 
            : ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius)),
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text('Description', style: TextStyle(color: Colors.black54, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        widget.tribe.desc,
                        style: TextStyle(
                          color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'TribesRounded',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text('Chief', style: TextStyle(color: Colors.black54, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          StreamBuilder<UserData>(
                            stream: DatabaseService().userData(widget.tribe.founder),
                            builder: (context, snapshot) {

                              if(snapshot.hasData) {
                                return UserAvatar(currentUserID: currentUser.uid, user: snapshot.data, color: widget.tribe.color);
                              } else if(snapshot.hasError) {
                                print('Error getting founder user data: ${snapshot.error.toString()}');
                                return UserAvatarPlaceholder(child: Center(child: CustomAwesomeIcon(icon: FontAwesomeIcons.exclamationCircle)));
                              } else {
                                return UserAvatarPlaceholder();
                              }
                              
                            }
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text('Password', style: TextStyle(color: Colors.black54, fontFamily: 'TribesRounded', fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(12.0),
                      child: Text(widget.tribe.password, 
                        style: TextStyle(
                          fontFamily: 'TribesRounded',
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          letterSpacing: 6.0,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
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
                                                    text: widget.tribe.name,
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
                                              decoration: Decorations.tribeDetailsInput.copyWith(
                                                hintText: widget.tribe.name,
                                                labelStyle: TextStyle(
                                                  color: widget.tribe.color ?? Constants.inputLabelColor,
                                                  fontFamily: 'TribesRounded',
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                  borderSide: BorderSide(color: widget.tribe.color.withOpacity(0.5) ?? Constants.inputEnabledColor, width: 2.0),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                  borderSide: BorderSide(
                                                    color: widget.tribe.color ?? Constants.inputFocusColor, 
                                                    width: 2.0
                                                  ),
                                                )
                                              ),
                                              onChanged: (val) {
                                                if (val == widget.tribe.name) {
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
                                              color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor,
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
                                            DatabaseService().deleteTribe(widget.tribe.id);
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
                                        color: widget.tribe.color ?? DynamicTheme.of(context).data.primaryColor
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
                                      DatabaseService().leaveTribe(currentUser.uid, widget.tribe.id);
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
                    ),
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