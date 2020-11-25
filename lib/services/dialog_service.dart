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

setUpCustomDialogUI() {
  DialogService dialogService = locator<DialogService>();

  _buildRetryDialog(DialogRequest dialogRequest, bool isDark) {
    ThemeData theme = isDark ? darkTheme : lightTheme;
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

  _buildConfirmDialog(DialogRequest dialogRequest, bool isDark) {
    ThemeData theme = isDark ? darkTheme : lightTheme;
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

  _buildInfoDialog(DialogRequest dialogRequest, bool isDark) {
    ThemeData theme = isDark ? darkTheme : lightTheme;
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

  // Retry Dialog
  dialogService.registerCustomDialogBuilder(
    variant: DialogType.RETRY_LIGHT,
    builder: (BuildContext context, DialogRequest dialogRequest) =>
        _buildRetryDialog(dialogRequest, false),
  );
  dialogService.registerCustomDialogBuilder(
    variant: DialogType.RETRY_DARK,
    builder: (BuildContext context, DialogRequest dialogRequest) =>
        _buildRetryDialog(dialogRequest, true),
  );

  // Confrim Dialog
  dialogService.registerCustomDialogBuilder(
    variant: DialogType.CONFIRM_LIGHT,
    builder: (BuildContext context, DialogRequest dialogRequest) =>
        _buildConfirmDialog(dialogRequest, false),
  );
  dialogService.registerCustomDialogBuilder(
    variant: DialogType.CONFIRM_DARK,
    builder: (BuildContext context, DialogRequest dialogRequest) =>
        _buildConfirmDialog(dialogRequest, true),
  );

  // Info Dialog
  dialogService.registerCustomDialogBuilder(
    variant: DialogType.INFO_LIGHT,
    builder: (BuildContext context, DialogRequest dialogRequest) =>
        _buildInfoDialog(dialogRequest, false),
  );
  dialogService.registerCustomDialogBuilder(
    variant: DialogType.INFO_DARK,
    builder: (BuildContext context, DialogRequest dialogRequest) =>
        _buildInfoDialog(dialogRequest, true),
  );
}
