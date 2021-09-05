import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/tribe/dialogs/tribe_settings/tribe_settings_view_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_button.dart';
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/discard_changes_dialog.dart';
import 'package:tribes/shared/widgets/loading.dart';

class TribeSettingsView extends ViewModelWidget<TribeSettingsViewModel> {
  @override
  Widget build(BuildContext context, TribeSettingsViewModel model) {
    ThemeData themeData = Theme.of(context);

    _buildAppBar() {
      return AppBar(
        elevation: 0.0,
        backgroundColor: themeData.backgroundColor,
        leading: IconButton(
          icon: CustomAwesomeIcon(
            icon: Platform.isIOS
                ? FontAwesomeIcons.chevronLeft
                : FontAwesomeIcons.arrowLeft,
            color: model.currentTribeColor,
          ),
          splashColor: Colors.transparent,
          onPressed: () {
            if (model.edited) {
              showDialog(
                  context: context,
                  builder: (context) => DiscardChangesDialog());
            } else {
              model.back();
            }
          },
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: model.currentTribeColor,
            fontFamily: 'TribesRounded',
            fontSize: Constants.defaultDialogTitleFontSize,
            fontWeight: Constants.defaultDialogTitleFontWeight,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: CustomAwesomeIcon(
              icon: model.secret
                  ? FontAwesomeIcons.solidEyeSlash
                  : FontAwesomeIcons.eye,
              color: (model.tribeColor ?? Constants.primaryColor)
                  .withOpacity(model.secret ? 0.6 : 1.0),
            ),
            onPressed: () {
              if (model.firstToggle && !model.originalSecret) {
                model.setFirstToggle(false);

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(Constants.dialogCornerRadius),
                      ),
                    ),
                    title: Text(
                      'Secret Tribe',
                      style: TextStyle(
                        fontFamily: 'TribesRounded',
                        fontWeight: Constants.defaultDialogTitleFontWeight,
                        fontSize: Constants.defaultDialogTitleFontSize,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          'Abort',
                          style: TextStyle(
                            color: model.currentTribeColor,
                            fontFamily: 'TribesRounded',
                          ),
                        ),
                        onPressed: model.back,
                      ),
                      TextButton(
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: model.currentTribeColor,
                            fontFamily: 'TribesRounded',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          model.toggleSecret();
                          model.back();
                        },
                      ),
                    ],
                    content: Container(
                      child: RichText(
                        text: TextSpan(
                          text: 'This will make your Tribe',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'TribesRounded',
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' secret ',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'TribesRounded',
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                              text: 'and can only be found by typing in the',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'TribesRounded',
                              ),
                            ),
                            TextSpan(
                              text: ' exact ',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'TribesRounded',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Tribe name.',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'TribesRounded',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                model.toggleSecret();
              }
            },
          ),
          IconButton(
            icon: CustomAwesomeIcon(
              icon: FontAwesomeIcons.palette,
              color: model.currentTribeColor,
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(Constants.dialogCornerRadius),
                  ),
                ),
                title: Text(
                  'Pick a Tribe color',
                  style: TextStyle(
                    fontFamily: 'TribesRounded',
                    fontWeight: Constants.defaultDialogTitleFontWeight,
                    fontSize: Constants.defaultDialogTitleFontSize,
                  ),
                ),
                content: SingleChildScrollView(
                  child: BlockPicker(
                    availableColors: Constants.defaultTribeColors,
                    pickerColor: model.currentTribeColor,
                    onColorChanged: model.changeColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.0),
        ],
      );
    }

    _buildDeleteTribeButton() {
      return Align(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                bool isDeleteButtonDisabled = true;

                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(Constants.dialogCornerRadius),
                        ),
                      ),
                      backgroundColor: Constants.profileSettingsBackgroundColor,
                      title: RichText(
                        text: TextSpan(
                          text: 'Please type ',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'TribesRounded',
                            fontWeight: FontWeight.normal,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: model.name,
                              style: TextStyle(
                                fontFamily: 'TribesRounded',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' to delete this Tribe.',
                              style: TextStyle(
                                fontFamily: 'TribesRounded',
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      content: Container(
                        child: TextFormField(
                          cursorRadius: Radius.circular(1000),
                          textCapitalization: TextCapitalization.words,
                          decoration: Decorations.tribeSettingsInput.copyWith(
                            hintText: model.name,
                            labelStyle: TextStyle(
                              color: model.currentTribeColor,
                              fontFamily: 'TribesRounded',
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              borderSide: BorderSide(
                                color: model.currentTribeColor.withOpacity(
                                  0.5,
                                ),
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
                          onChanged: (value) => setState(() {
                            isDeleteButtonDisabled =
                                model.onDeleteTribeCheckChanged(value);
                          }),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: model.currentTribeColor,
                              fontFamily: 'TribesRounded',
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Dialog: "Please type..."
                          },
                        ),
                        TextButton(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: isDeleteButtonDisabled
                                  ? Colors.black54
                                  : Colors.red,
                              fontFamily: 'TribesRounded',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: isDeleteButtonDisabled
                              ? null
                              : model.onDeleteTribe,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          child: Text(
            'Delete Tribe',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'TribesRounded',
              color: Colors.red,
            ),
          ),
        ),
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
          label: Text(
            'Save',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'TribesRounded',
            ),
          ),
          labelColor: Colors.white,
          onPressed: model.edited ? model.onSaveTribeSettings : null,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height:
            MediaQuery.of(context).size.height * (model.edited ? 0.65 : 0.55),
        alignment: Alignment.topCenter,
        child: StreamBuilder<Tribe>(
            stream: model.tribeDetailsStream,
            builder: (context, snapshot) {
              model.setTribe(snapshot.hasData ? snapshot.data : model.tribe);

              return model.isBusy
                  ? Loading(color: model.currentTribeColor)
                  : Scaffold(
                      backgroundColor: themeData.backgroundColor,
                      appBar: _buildAppBar(),
                      body: ScrollConfiguration(
                        behavior: CustomScrollBehavior(),
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: ListView(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.fromLTRB(
                                  16.0,
                                  8.0,
                                  16.0,
                                  model.edited ? 92.0 : 16.0,
                                ),
                                children: <Widget>[
                                  Container(
                                    child: Form(
                                      key: model.formKey,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          TextFormField(
                                            focusNode: model.nameFocus,
                                            cursorRadius: Radius.circular(1000),
                                            initialValue: model.name,
                                            maxLength:
                                                Constants.tribeNameMaxLength,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            decoration: Decorations
                                                .tribeSettingsInput
                                                .copyWith(
                                              labelText: 'Name',
                                              labelStyle: TextStyle(
                                                color: model.currentTribeColor,
                                                fontFamily: 'TribesRounded',
                                              ),
                                              hintText: 'Tribe name',
                                              counterStyle: TextStyle(
                                                color: model.currentTribeColor
                                                    .withOpacity(0.5),
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
                                                  color:
                                                      model.currentTribeColor,
                                                  width: 2.0,
                                                ),
                                              ),
                                            ),
                                            validator: model.nameValidator,
                                            onChanged: model.onNameChanged,
                                            onFieldSubmitted:
                                                model.onNameSubmitted,
                                          ),
                                          SizedBox(
                                            height: Constants.smallSpacing,
                                          ),
                                          TextFormField(
                                            focusNode: model.descFocus,
                                            cursorRadius: Radius.circular(1000),
                                            initialValue: model.desc,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLength:
                                                Constants.tribeDescMaxLength,
                                            maxLines: null,
                                            decoration: Decorations
                                                .tribeSettingsInput
                                                .copyWith(
                                              labelText: 'Description',
                                              labelStyle: TextStyle(
                                                color: model.tribeColor,
                                                fontFamily: 'TribesRounded',
                                              ),
                                              hintText: 'Descriptive text',
                                              counterStyle: TextStyle(
                                                color: model.currentTribeColor
                                                    .withOpacity(0.5),
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
                                                  color:
                                                      model.currentTribeColor,
                                                  width: 2.0,
                                                ),
                                              ),
                                            ),
                                            onChanged: model.onDescChanged,
                                          ),
                                          SizedBox(
                                            height: Constants.smallSpacing,
                                          ),
                                          TextFormField(
                                            focusNode: model.passwordFocus,
                                            cursorRadius: Radius.circular(1000),
                                            initialValue: model.password,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            keyboardType: TextInputType.number,
                                            inputFormatters:
                                                model.passwordInputFormatters,
                                            maxLength: 6,
                                            maxLines: null,
                                            validator: model.passwordValidator,
                                            decoration: Decorations
                                                .tribeSettingsInput
                                                .copyWith(
                                              labelText: 'Password',
                                              labelStyle: TextStyle(
                                                color: model.currentTribeColor,
                                                fontFamily: 'TribesRounded',
                                              ),
                                              hintText: 'eg. 123456',
                                              counterStyle: TextStyle(
                                                color: model.currentTribeColor
                                                    .withOpacity(0.5),
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
                                                  color:
                                                      model.currentTribeColor,
                                                  width: 2.0,
                                                ),
                                              ),
                                            ),
                                            onChanged: model.onPasswordChanged,
                                          ),
                                          SizedBox(
                                              height: Constants.smallSpacing),
                                          model.hasError
                                              ? Text(
                                                  model.currentError,
                                                  style: TextStyle(
                                                    color: Constants.errorColor,
                                                    fontSize:
                                                        Constants.errorFontSize,
                                                  ),
                                                )
                                              : SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildDeleteTribeButton(),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: _buildSaveButton(),
                            ),
                          ],
                        ),
                      ),
                    );
            }),
      ),
    );
  }
}
