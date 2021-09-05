import 'package:flutter/material.dart';

/* _buildActionBar({
  Widget leading,
  Widget title,
  Widget subtitle,
  Widget trailing,
}) {
  return Container(
    height: kToolbarHeight,
    child: NavigationToolbar(
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: leading,
      ),
      middle: title,
      trailing: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: trailing,
      ),
    ),
  );
}

extension ActionBarWidgetExtension on Widget {
  addActionBar({
    Widget leading,
    Widget title,
    Widget subtitle,
    Widget trailing,
  }) {
    return _buildActionBar(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    );
  }
}

extension ActionBarStateExtension on State {
  addActionBar({
    Widget leading,
    Widget title,
    Widget subtitle,
    Widget trailing,
  }) {
    return _buildActionBar(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
    );
  }
} */

extension PaddedWidget on Widget {
  Padding withPadding(EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }
}

extension VisibleWidget on Widget {
  Visibility isVisible(bool visible) {
    return Visibility(
      visible: visible,
      child: this,
    );
  }

  Visibility hideButFillSpace() {
    return Visibility(
      visible: false,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: this
    );
  }
}

extension OnlyDevelopment on Widget {
  Visibility onlyDevelopment(bool disable, {bool keepSpace = true}) {
    return Visibility(
      visible: !disable,
      maintainSize: keepSpace,
      maintainAnimation: keepSpace,
      maintainState: keepSpace,
      child: this
    );
  }
}

/*extension LeadingIconWidget on Widget {
  Widget withIcon(CustomAwesomeIcon icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [icon, this.withPadding(const EdgeInsets.only(left: 4.0))],
    );
  }
}

extension DisabledWidget on Widget {
  Widget isDisabled(bool disabled) {
    return AbsorbPointer(
      absorbing: disabled,
      child: this,
    );
  }
}

extension BusyWidget on Widget {
  Widget isBusy(bool isBusy, ThemeData theme) {
    return isBusy
        ? SizedBox.expand(
            child: Container(
              color: theme.backgroundColor,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ),
            ),
          )
        : this;
  }
} */
