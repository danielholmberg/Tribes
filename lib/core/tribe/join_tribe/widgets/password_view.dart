import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/tribe/join_tribe/widgets/password_view_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/decorations.dart' as Decorations;
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';

class PasswordView extends StatelessWidget {
  final Tribe activeTribe;
  final Function showJoinedSnackbar;
  const PasswordView({
    Key key,
    @required this.activeTribe,
    this.showJoinedSnackbar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PasswordViewModel>.reactive(
        viewModelBuilder: () => PasswordViewModel(
              activeTribe: activeTribe,
              showJoinedSnackbar: showJoinedSnackbar,
            ),
        onModelReady: (model) => model.initState(context),
        builder: (context, model, child) {
          return ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(Constants.dialogCornerRadius),
              ),
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
                          fontSize: Constants.defaultDialogTitleFontSize,
                          fontWeight: Constants.defaultDialogTitleFontWeight,
                        ),
                      ),
                    ),
                    SizedBox(height: Constants.defaultSpacing),
                    model.isBusy
                        ? Loading(color: activeTribe.color)
                        : Container(
                            child: Form(
                              key: model.passwordFormKey,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                    width: 30,
                                    height: 60,
                                    child: TextFormField(
                                      focusNode: model.nodeOne,
                                      autofocus: true,
                                      textInputAction: TextInputAction.next,
                                      showCursor: false,
                                      enableInteractiveSelection: false,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: model.inputFormatters,
                                      maxLength: 1,
                                      obscureText: true,
                                      buildCounter: (
                                        BuildContext context, {
                                        int currentLength,
                                        int maxLength,
                                        bool isFocused,
                                      }) =>
                                          null,
                                      style: TextStyle(
                                        color: model.activeTribeColor,
                                      ),
                                      decoration: Decorations.tribePasswordInput
                                          .copyWith(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.one.isEmpty
                                                ? Colors.black26
                                                : model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: model.onFirstDigitChanged,
                                      onFieldSubmitted:
                                          model.onFirstDigitSubmitted,
                                    ),
                                  ),
                                  SizedBox(width: Constants.defaultPadding),
                                  Container(
                                    width: 30,
                                    height: 60,
                                    child: TextFormField(
                                      focusNode: model.nodeTwo,
                                      textInputAction: TextInputAction.next,
                                      showCursor: false,
                                      enableInteractiveSelection: false,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: model.inputFormatters,
                                      maxLength: 1,
                                      obscureText: true,
                                      buildCounter: (
                                        BuildContext context, {
                                        int currentLength,
                                        int maxLength,
                                        bool isFocused,
                                      }) =>
                                          null,
                                      style: TextStyle(
                                        color: model.activeTribeColor,
                                      ),
                                      decoration: Decorations.tribePasswordInput
                                          .copyWith(
                                        labelStyle: TextStyle(
                                          color: model.activeTribeColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.two.isEmpty
                                                ? Colors.black26
                                                : model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: model.onSecondDigitChanged,
                                      onFieldSubmitted:
                                          model.onSecondDigitSubmitted,
                                    ),
                                  ),
                                  SizedBox(width: Constants.defaultPadding),
                                  Container(
                                    width: 30,
                                    height: 60,
                                    child: TextFormField(
                                      focusNode: model.nodeThree,
                                      textInputAction: TextInputAction.next,
                                      showCursor: false,
                                      enableInteractiveSelection: false,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: model.inputFormatters,
                                      maxLength: 1,
                                      obscureText: true,
                                      buildCounter: (
                                        BuildContext context, {
                                        int currentLength,
                                        int maxLength,
                                        bool isFocused,
                                      }) =>
                                          null,
                                      style: TextStyle(
                                        color: model.activeTribeColor,
                                      ),
                                      decoration: Decorations.tribePasswordInput
                                          .copyWith(
                                        labelStyle: TextStyle(
                                          color: model.activeTribeColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                          borderSide: BorderSide(
                                            color: model.three.isEmpty
                                                ? Colors.black26
                                                : model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: model.onThirdDigitChanged,
                                      onFieldSubmitted:
                                          model.onThirdDigitSubmitted,
                                    ),
                                  ),
                                  SizedBox(width: Constants.defaultPadding),
                                  Container(
                                    width: 30,
                                    height: 60,
                                    child: TextFormField(
                                      focusNode: model.nodeFour,
                                      textInputAction: TextInputAction.next,
                                      showCursor: false,
                                      enableInteractiveSelection: false,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: model.inputFormatters,
                                      maxLength: 1,
                                      obscureText: true,
                                      buildCounter: (
                                        BuildContext context, {
                                        int currentLength,
                                        int maxLength,
                                        bool isFocused,
                                      }) =>
                                          null,
                                      style: TextStyle(
                                        color: model.activeTribeColor,
                                      ),
                                      decoration: Decorations.tribePasswordInput
                                          .copyWith(
                                        labelStyle: TextStyle(
                                          color: model.activeTribeColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.four.isEmpty
                                                ? Colors.black26
                                                : model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: model.onFourthDigitChanged,
                                      onFieldSubmitted:
                                          model.onFourthDigitSubmitted,
                                    ),
                                  ),
                                  SizedBox(width: Constants.defaultPadding),
                                  Container(
                                    width: 30,
                                    height: 60,
                                    child: TextFormField(
                                      focusNode: model.nodeFive,
                                      textInputAction: TextInputAction.next,
                                      showCursor: false,
                                      enableInteractiveSelection: false,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: model.inputFormatters,
                                      maxLength: 1,
                                      obscureText: true,
                                      buildCounter: (
                                        BuildContext context, {
                                        int currentLength,
                                        int maxLength,
                                        bool isFocused,
                                      }) =>
                                          null,
                                      style: TextStyle(
                                        color: model.activeTribeColor,
                                      ),
                                      decoration: Decorations.tribePasswordInput
                                          .copyWith(
                                        labelStyle: TextStyle(
                                          color: model.activeTribeColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.five.isEmpty
                                                ? Colors.black26
                                                : model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: model.onFifthDigitChanged,
                                      onFieldSubmitted:
                                          model.onFifthDigitSubmitted,
                                    ),
                                  ),
                                  SizedBox(width: Constants.defaultPadding),
                                  Container(
                                    width: 30,
                                    height: 60,
                                    child: TextFormField(
                                      focusNode: model.nodeSix,
                                      textInputAction: TextInputAction.done,
                                      showCursor: false,
                                      enableInteractiveSelection: false,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: model.inputFormatters,
                                      maxLength: 1,
                                      obscureText: true,
                                      buildCounter: (
                                        BuildContext context, {
                                        int currentLength,
                                        int maxLength,
                                        bool isFocused,
                                      }) =>
                                          null,
                                      style: TextStyle(
                                        color: model.activeTribeColor,
                                      ),
                                      decoration: Decorations.tribePasswordInput
                                          .copyWith(
                                        labelStyle: TextStyle(
                                          color: model.activeTribeColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.six.isEmpty
                                                ? Colors.black26
                                                : model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          borderSide: BorderSide(
                                            color: model.activeTribeColor,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                      onChanged: model.onSixthDigitChanged,
                                      onFieldSubmitted:
                                          model.onSixthDigitSubmitted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    Text(
                      model.currentError,
                      style: TextStyle(
                        color: Constants.errorColor,
                        fontSize: 12,
                        fontFamily: 'TribesRounded',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
