import 'package:auto_size_text/auto_size_text.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tribes/models/Post.dart';
import 'package:tribes/models/Tribe.dart';
import 'package:tribes/models/User.dart';
import 'package:tribes/services/database.dart';
import 'package:tribes/shared/widgets/CustomScrollBehavior.dart';
import 'package:tribes/shared/widgets/Loading.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;

class JoinTribe extends StatefulWidget {
  /* final List<String> joinedTribesIDs;
  JoinTribe(this.joinedTribesIDs); */

  @override
  _JoinTribeState createState() => _JoinTribeState();
}

class _JoinTribeState extends State<JoinTribe> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Tribe> _tribesList = [];
  List<Tribe> _searchResult = [];
  bool loading = false;
  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final UserData currentUser = Provider.of<UserData>(context);
    print('Building JoinTribe()...');
    print('Current user ${currentUser.toString()}');
    
    _showJoinedSnackbar(Tribe joinedTribe) {
      Future.delayed(Duration(milliseconds: 300), () => 
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: RichText(
              text: TextSpan(
                text: 'Successfully joined Tribe ',
                style: TextStyle(fontFamily: 'TribesRounded', fontWeight: FontWeight.normal),
                children: <TextSpan>[
                  TextSpan(text: joinedTribe.name, 
                    style: TextStyle(
                      fontFamily: 'TribesRounded', 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            duration: Duration(milliseconds: 1000),
          )
        )
      );
      
    }

    _showPasswordDialog(Tribe activeTribe) {
      return showDialog(
        context: context,
        builder: (context) {
          final _passwordFormKey = GlobalKey<FormState>();
          String one = '', two = '', three = '', four = '', five = '', six = '';
          bool loadingDialog = false;
          FocusNode oneNode = new FocusNode();
          FocusNode twoNode = new FocusNode();
          FocusNode threeNode = new FocusNode();
          FocusNode fourNode = new FocusNode();
          FocusNode fiveNode = new FocusNode();
          FocusNode sixNode = new FocusNode();

          return StatefulBuilder(
            builder: (context, setState) { 
              return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius))),
              contentPadding: EdgeInsets.all(0.0),
              backgroundColor: DynamicTheme.of(context).data.backgroundColor,
              content: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(Constants.dialogCornerRadius)),
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Enter Tribe Password',
                            style: TextStyle(
                              fontFamily: 'TribesRounded',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: Constants.defaultSpacing),
                        loadingDialog ? CircularProgressIndicator() : Container(
                          child: Form(
                            key: _passwordFormKey,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  width: 30,
                                  height: 60,
                                  child: TextFormField(
                                    focusNode: oneNode,
                                    textInputAction: TextInputAction.next,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                    cursorColor: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                    style: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                    decoration: Decorations.tribePasswordInput.copyWith(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: one.isEmpty ? Colors.black26 : activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      if(activeTribe.password == '$val$two$three$four$five$six') {
                                        setState(() {
                                          loadingDialog = true;
                                        });

                                        DatabaseService().addUserToTribe(currentUser.uid, activeTribe.id);
                                        _showJoinedSnackbar(activeTribe);

                                        Navigator.of(context).pop();
                                      } else {
                                        setState(() => one = val);
                                        FocusScope.of(context).requestFocus(val.isEmpty ? oneNode : twoNode);
                                      }
                                    },
                                    onFieldSubmitted: (String value) {
                                      FocusScope.of(context).requestFocus(twoNode);
                                    },
                                  ),
                                ),
                                SizedBox(width: Constants.defaultPadding),
                                Container(
                                  width: 30,
                                  height: 60,
                                  child: TextFormField(
                                    focusNode: twoNode,
                                    textInputAction: TextInputAction.next,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                    cursorColor: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                    style: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                    decoration: Decorations.tribePasswordInput.copyWith(
                                      labelStyle: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: two.isEmpty ? Colors.black26 : activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      if(activeTribe.password == '$one$val$three$four$five$six') {
                                        setState(() {
                                          loadingDialog = true;
                                        });

                                        DatabaseService().addUserToTribe(currentUser.uid, activeTribe.id);
                                        _showJoinedSnackbar(activeTribe);

                                        Navigator.of(context).pop();
                                      } else {
                                        setState(() => two = val);
                                        FocusScope.of(context).requestFocus(val.isEmpty ? oneNode : threeNode);
                                      }
                                    },
                                    onFieldSubmitted: (String value) {
                                      FocusScope.of(context).requestFocus(threeNode);
                                    },
                                  ),
                                ),
                                SizedBox(width: Constants.defaultPadding),
                                Container(
                                  width: 30,
                                  height: 60,
                                  child: TextFormField(
                                    focusNode: threeNode,
                                    textInputAction: TextInputAction.next,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                    cursorColor: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                    style: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                    decoration: Decorations.tribePasswordInput.copyWith(
                                      labelStyle: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: three.isEmpty ? Colors.black26 : activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      if(activeTribe.password == '$one$two$val$four$five$six') {
                                        setState(() {
                                          loadingDialog = true;
                                        });

                                        DatabaseService().addUserToTribe(currentUser.uid, activeTribe.id);
                                        _showJoinedSnackbar(activeTribe);

                                        Navigator.of(context).pop();
                                      } else {
                                        setState(() => three = val);
                                        FocusScope.of(context).requestFocus(val.isEmpty ? twoNode : fourNode);
                                      }
                                    },
                                    onFieldSubmitted: (String value) {
                                      FocusScope.of(context).requestFocus(fourNode);
                                    },
                                  ),
                                ),
                                SizedBox(width: Constants.defaultPadding),
                                Container(
                                  width: 30,
                                  height: 60,
                                  child: TextFormField(
                                    focusNode: fourNode,
                                    textInputAction: TextInputAction.next,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                    cursorColor: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                    style: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                    decoration: Decorations.tribePasswordInput.copyWith(
                                      labelStyle: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: four.isEmpty ? Colors.black26 : activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      if(activeTribe.password == '$one$two$three$val$five$six') {
                                        setState(() {
                                          loadingDialog = true;
                                        });

                                        DatabaseService().addUserToTribe(currentUser.uid, activeTribe.id);
                                        _showJoinedSnackbar(activeTribe);

                                        Navigator.of(context).pop();
                                      } else {
                                        setState(() => four = val);
                                        FocusScope.of(context).requestFocus(val.isEmpty ? threeNode : fiveNode);
                                      }
                                    },
                                    onFieldSubmitted: (String value) {
                                      FocusScope.of(context).requestFocus(fiveNode);
                                    },
                                  ),
                                ),
                                SizedBox(width: Constants.defaultPadding),
                                Container(
                                  width: 30,
                                  height: 60,
                                  child: TextFormField(
                                    focusNode: fiveNode,
                                    textInputAction: TextInputAction.next,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                    cursorColor: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                    style: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                    decoration: Decorations.tribePasswordInput.copyWith(
                                      labelStyle: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: five.isEmpty ? Colors.black26 : activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      if(activeTribe.password == '$one$two$three$four$val$six') {
                                        setState(() {
                                          loadingDialog = true;
                                        });

                                        DatabaseService().addUserToTribe(currentUser.uid, activeTribe.id);
                                        _showJoinedSnackbar(activeTribe);

                                        Navigator.of(context).pop();
                                      } else {
                                        setState(() => five = val);
                                        FocusScope.of(context).requestFocus(val.isEmpty ? fourNode : sixNode);
                                      }
                                    },
                                    onFieldSubmitted: (String value) {
                                      FocusScope.of(context).requestFocus(sixNode);
                                    },
                                  ),
                                ),
                                SizedBox(width: Constants.defaultPadding),
                                Container(
                                  width: 30,
                                  height: 60,
                                  child: TextFormField(
                                    focusNode: sixNode,
                                    textInputAction: TextInputAction.done,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                    cursorColor: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor,
                                    style: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                    decoration: Decorations.tribePasswordInput.copyWith(
                                      labelStyle: TextStyle(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: six.isEmpty ? Colors.black26 : activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide(color: activeTribe.color ?? DynamicTheme.of(context).data.primaryColor, width: 2.0),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      if(activeTribe.password == '$one$two$three$four$five$val') {
                                        setState(() {
                                          loadingDialog = true;
                                        });

                                        DatabaseService().addUserToTribe(currentUser.uid, activeTribe.id);
                                        _showJoinedSnackbar(activeTribe);

                                        Navigator.of(context).pop();
                                      } else {
                                        setState(() => six = val);
                                        FocusScope.of(context).requestFocus(val.isEmpty ? fiveNode : sixNode);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        }
      );
    }

    _tribeTile(Tribe tribe) {
      return GestureDetector(
        onTap: () => _showPasswordDialog(tribe),
        child: Container(
          margin: EdgeInsets.all(6.0),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: tribe.color,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: tribe.color,
                  blurRadius: 10,
                  offset: Offset(0, 0),
                ),
              ]),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AutoSizeText(
                tribe.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                minFontSize: 10.0,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'TribesRounded',
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: StreamBuilder<List<Post>>(
                  stream: DatabaseService().posts(tribe.id)
                    .map((list) => list.documents
                    .map((doc) => Post.fromSnapshot(doc))
                    .toList()
                  ),
                  builder: (context, snapshot) {
                    var postsList = snapshot.hasData ? snapshot.data : []; 

                    return Row(
                      children: <Widget>[
                        Icon(
                          Icons.view_list,
                          color: Constants.buttonIconColor,
                          size: 20,
                        ),
                        SizedBox(width: Constants.tinySpacing),
                        Text(
                          '${postsList.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'TribesRounded',
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  children: <Widget>[
                    Text(
                      '${tribe.members.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TribesRounded',
                      ),
                    ),
                    SizedBox(width: Constants.tinySpacing),
                    Icon(
                      Icons.group,
                      color: Constants.buttonIconColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return loading ? Loading() : Scaffold(
      key: _scaffoldKey,
      backgroundColor: DynamicTheme.of(context).data.primaryColor,
      body: SafeArea(
        child: Container(
          color: DynamicTheme.of(context).data.backgroundColor,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: StreamBuilder<List<Tribe>>(
                  stream: DatabaseService().notYetJoinedTribes(currentUser.uid),
                  builder: (context, snapshot) {

                    if(snapshot.hasData) {
                      _tribesList = snapshot.data;

                      return Container(
                        child: ScrollConfiguration(
                          behavior: CustomScrollBehavior(), 
                          child: _searchResult.length != 0 || controller.text.isNotEmpty
                          ? GridView.builder(
                            padding: EdgeInsets.fromLTRB(12.0, 80.0, 12.0, 12.0),
                            itemCount: _searchResult.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2
                            ),
                            itemBuilder: (context, i) {
                              return _tribeTile(_searchResult[i]); 
                            }
                          )
                          : GridView.builder(
                            padding: EdgeInsets.fromLTRB(12.0, 80.0, 12.0, 12.0),
                            itemCount: _tribesList.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemBuilder: (context, i) {
                              return _tribeTile(_tribesList[i]);
                            },
                          ),
                        ),
                      );
                    } else if(snapshot.hasError){
                      print('Error retrieving not yet joined Tribes: ${snapshot.error.toString()}');
                      return Center(child: Text('Unable to retrieve Tribes'));
                    } else {
                      return Center(child: Text('Unable to retrieve Tribes'));
                    }
                  }
                )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Card(
                  margin: EdgeInsets.all(12.0),
                  elevation: 8.0,
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.arrow_back, color: DynamicTheme.of(context).data.primaryColor),
                        ),
                        SizedBox(width: Constants.defaultSpacing),
                        Icon(Icons.search, color: Colors.black54),
                      ],
                    ),
                    title: TextField(
                      controller: controller,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Find your Tribe', 
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontFamily: 'TribesRounded',
                          fontSize: 16,
                          color: Colors.black54.withOpacity(0.3),
                        ),
                      ),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: IconButton(icon: Icon(Icons.cancel), onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _tribesList.forEach((tribe) {
      if (tribe.name.contains(text))
        _searchResult.add(tribe);
    });

    setState(() {});
  }
}