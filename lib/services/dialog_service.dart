import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:tribes/shared/constants.dart';
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';

import '../locator.dart';
import '../shared/extensions.dart';
import '../theme.dart';

enum DialogType {
  BASIC_LIGHT,
  CONFIRM_LIGHT,
  RETRY_LIGHT,
  INFO_LIGHT,

  BASIC_DARK,
  CONFIRM_DARK,
  RETRY_DARK,
  INFO_DARK,
}

final DialogService dialogService = locator<DialogService>();

class _RetryDialog extends StatelessWidget {
  final DialogRequest dialogRequest;
  final bool isDark;
  const _RetryDialog({Key key, this.dialogRequest, this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = isDark ? darkTheme : lightTheme;

    return Dialog(
      backgroundColor: theme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              dialogRequest.title ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ).withPadding(const EdgeInsets.only(bottom: 10)),
            Text(
              dialogRequest.description ?? '',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ).withPadding(const EdgeInsets.only(bottom: 20)),
            GestureDetector(
              // Complete the dialog when you're done with it to return some data
              onTap: () => dialogService.completeDialog(
                DialogResponse(confirmed: true),
              ),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.buttonColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomAwesomeIcon(icon: FontAwesomeIcons.redoAlt)
                        .withPadding(const EdgeInsets.only(right: 12))
                        .isVisible(dialogRequest.showIconInMainButton),
                    Text(
                      dialogRequest.mainButtonTitle ?? 'Retry',
                      style: theme.textTheme.button.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final DialogRequest dialogRequest;
  final bool isDark;
  const _ConfirmDialog({Key key, this.dialogRequest, this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = isDark ? darkTheme : lightTheme;

    return Dialog(
      backgroundColor: theme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              dialogRequest.title ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ).withPadding(const EdgeInsets.only(bottom: 10)),
            Text(
              dialogRequest.description ?? '',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ).withPadding(const EdgeInsets.only(bottom: 20)),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => dialogService.completeDialog(
                    DialogResponse(confirmed: false),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: declineButtonColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomAwesomeIcon(icon: FontAwesomeIcons.times)
                            .withPadding(const EdgeInsets.only(right: 12))
                            .isVisible(dialogRequest.showIconInSecondaryButton),
                        Text(
                          dialogRequest.secondaryButtonTitle ?? 'Cancel',
                          style: theme.textTheme.button,
                        ),
                      ],
                    ),
                  ),
                ).isVisible(dialogRequest.secondaryButtonTitle.isNotEmpty),
                GestureDetector(
                  // Complete the dialog when you're done with it to return some data
                  onTap: () => dialogService.completeDialog(
                    DialogResponse(confirmed: true),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: confirmButtonColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomAwesomeIcon(
                          icon: FontAwesomeIcons.check,
                        )
                            .withPadding(const EdgeInsets.only(right: 12))
                            .isVisible(dialogRequest.showIconInMainButton),
                        Text(
                          dialogRequest.mainButtonTitle ?? 'OK',
                          style: theme.textTheme.button,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoDialog extends StatelessWidget {
  final DialogRequest dialogRequest;
  final bool isDark;
  const _InfoDialog({Key key, this.dialogRequest, this.isDark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = isDark ? darkTheme : lightTheme;

    return Dialog(
      backgroundColor: theme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              dialogRequest.title ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ).withPadding(const EdgeInsets.only(bottom: 10)),
            Text(
              dialogRequest.description ?? '',
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ).withPadding(const EdgeInsets.only(bottom: 20)),
            GestureDetector(
              // Complete the dialog when you're done with it to return some data
              onTap: () => dialogService.completeDialog(
                DialogResponse(confirmed: true),
              ),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.buttonColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomAwesomeIcon(icon: FontAwesomeIcons.redoAlt)
                        .withPadding(const EdgeInsets.only(right: 12))
                        .isVisible(dialogRequest.showIconInMainButton),
                    Text(
                      dialogRequest.mainButtonTitle ?? 'OK',
                      style: theme.textTheme.button,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

setUpCustomDialogUI() {
  final dialogs = {
    DialogType.RETRY_LIGHT: (context, dialogRequest, completer) => _RetryDialog(dialogRequest: dialogRequest, isDark: false),
    DialogType.RETRY_DARK: (context, dialogRequest, completer) => _RetryDialog(dialogRequest: dialogRequest, isDark: true),
    DialogType.CONFIRM_LIGHT: (context, dialogRequest, completer) => _ConfirmDialog(dialogRequest: dialogRequest, isDark: false),
    DialogType.CONFIRM_DARK: (context, dialogRequest, completer) => _ConfirmDialog(dialogRequest: dialogRequest, isDark: true),
    DialogType.INFO_LIGHT: (context, dialogRequest, completer) => _InfoDialog(dialogRequest: dialogRequest, isDark: false),
    DialogType.INFO_DARK: (context, dialogRequest, completer) => _InfoDialog(dialogRequest: dialogRequest, isDark: true)
  };

  dialogService.registerCustomDialogBuilders(dialogs);
}
