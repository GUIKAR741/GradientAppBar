library new_gradient_app_bar;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const double _kLeadingWidth = kToolbarHeight;

class _ToolbarContainerLayout extends SingleChildLayoutDelegate {
  const _ToolbarContainerLayout();

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(height: kToolbarHeight);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, kToolbarHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_ToolbarContainerLayout oldDelegate) => false;
}

class NewGradientAppBar extends StatefulWidget implements PreferredSizeWidget {
  NewGradientAppBar({
    Key? key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.shape,
    this.gradient,
    this.brightness,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
  })  : assert(elevation == null || elevation >= 0.0),
        preferredSize = Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0)),
        super(key: key);

  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final ShapeBorder? shape;
  final Gradient? gradient;
  final Brightness? brightness;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  final bool primary;
  final bool? centerTitle;
  final double titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;

  @override
  final Size preferredSize;

  bool? _getEffectiveCenterTitle(ThemeData themeData) {
    if (centerTitle != null) return centerTitle;
    assert(true);
    switch (themeData.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return false;
      case TargetPlatform.iOS:
        return actions == null || actions!.length < 2;
      case TargetPlatform.linux:
        return false;
      case TargetPlatform.macOS:
        return false;
      case TargetPlatform.windows:
        return false;
    }
  }

  @override
  _NewGradientAppBarState createState() => _NewGradientAppBarState();
}

class _NewGradientAppBarState extends State<NewGradientAppBar> {
  static const double _defaultElevation = 4.0;

  void _handleDrawerButton() {
    Scaffold.of(context).openDrawer();
  }

  void _handleDrawerButtonEnd() {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    assert(!widget.primary || debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData themeData = Theme.of(context);
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool hasDrawer = widget.automaticallyImplyLeading && parentRoute?.canPop == true;
    final bool useCloseButton = !widget.primary;
    final bool effectiveCenterTitle = widget._getEffectiveCenterTitle(themeData);

    IconThemeData appBarIconTheme =
        widget.iconTheme ?? themeData.primaryIconTheme;
    IconThemeData actionsIconTheme =
        widget.actionsIconTheme ?? themeData.primaryIconTheme;
    TextStyle? appBarTextStyle = themeData.primaryTextTheme.headline6;
    TextStyle? actionsTextStyle = themeData.primaryTextTheme.subtitle1;

    if (widget.brightness != null) {
      final bool isDark = widget.brightness == Brightness.dark;
      appBarIconTheme = appBarIconTheme.copyWith(
        opacity: isDark ? 0.7 : 1.0,
      );
      actionsIconTheme = actionsIconTheme.copyWith(
        opacity: isDark ? 0.7 : 1.0,
      );
      appBarTextStyle = appBarTextStyle!.copyWith(
        color: isDark ? Colors.white : Colors.black87,
      );
      actionsTextStyle = actionsTextStyle!.copyWith(
        color: isDark ? Colors.white : Colors.black87,
      );
    }

    final SystemUiOverlayStyle overlayStyle =
        themeData.appBarTheme.systemOverlayStyle ??
            SystemUiOverlayStyle.light;
    final bool backwardsCompatibility = false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: backwardsCompatibility
          ? overlayStyle.copyWith(
              statusBarBrightness: widget.brightness,
            )
          : overlayStyle,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: Stack(
          children: <Widget>[
            if (widget.flexibleSpace != null)
              Positioned.fill(child: widget.flexibleSpace!),
            PositionedDirectional(
              top: 0.0,
              start: effectiveCenterTitle ? 0.0 : null,
              end: effectiveCenterTitle ? 0.0 : null,
              child: AppBar(
                backgroundColor: Colors.transparent,
                toolbarOpacity: widget.toolbarOpacity,
                bottomOpacity: widget.bottomOpacity,
                elevation: widget.elevation ?? _defaultElevation,
                shape: widget.shape,
                leading: widget.leading ??
                    (hasDrawer ? null : (useCloseButton ? null : Container())),
                title: widget.title != null
                    ? DefaultTextStyle(
                        style: appBarTextStyle!,
                        child: Semantics(
                          namesRoute: true,
                          child: widget.title!,
                          header: true,
                        ),
                      )
                    : null,
                actions: widget.actions != null
                    ? _buildActions(actionsTextStyle!, actionsIconTheme)
                    : null,
                centerTitle: effectiveCenterTitle,
                titleSpacing: widget.titleSpacing,
                toolbarOpacity: widget.toolbarOpacity,
                bottomOpacity: widget.bottomOpacity,
                titleTextStyle: appBarTextStyle,
                systemOverlayStyle: overlayStyle,
              ),
            ),
            if (widget.bottom != null)
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: widget.bottom!,
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(
      TextStyle actionsTextStyle, IconThemeData actionsIconTheme) {
    final List<Widget> actionButtons = <Widget>[];
    for (final Widget action in widget.actions!) {
      if (action is IconButton) {
        actionButtons.add(action);
      } else {
        actionButtons.add(Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconTheme.merge(
            data: actionsIconTheme,
            child: DefaultTextStyle(
              style: actionsTextStyle,
              child: action,
            ),
          ),
        ));
      }
    }
    return actionButtons;
  }
}
