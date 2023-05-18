import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? flexibleSpace;
  final Widget? bottom;
  final double? elevation;
  final Color? backgroundColor;
  final Brightness? brightness;
  final double toolbarOpacity;
  final double bottomOpacity;
  final double titleSpacing;
  final ShapeBorder? shape;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;

  CustomAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.backgroundColor,
    this.brightness,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.shape,
    this.iconTheme,
    this.actionsIconTheme,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool hasDrawer = widget.automaticallyImplyLeading && parentRoute?.canPop == true;
    final bool useCloseButton = !widget.primary;
    final bool effectiveCenterTitle = widget._getEffectiveCenterTitle(themeData);

    IconThemeData appBarIconTheme = widget.iconTheme ?? themeData.primaryIconTheme;
    IconThemeData actionsIconTheme = widget.actionsIconTheme ?? themeData.primaryIconTheme;
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

    final SystemUiOverlayStyle overlayStyle = themeData.appBarTheme.systemOverlayStyle ?? SystemUiOverlayStyle.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(statusBarBrightness: widget.brightness),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: Stack(
          children: <Widget>[
            if (widget.flexibleSpace != null) Positioned.fill(child: widget.flexibleSpace!),
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
                leading: widget.leading ?? (hasDrawer ? null : (useCloseButton ? null : Container())),
                title: widget.title != null
                    ? DefaultTextStyle(
                        style: appBarTextStyle!,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        child: Semantics(
                          child: widget.title!,
                          namesRoute: true,
                          container: true,
                        ),
                      )
                    : null,
                actions: _buildActions(context, appBarIconTheme, actionsIconTheme, actionsTextStyle),
                bottom: widget.bottom,
                brightness: widget.brightness,
                iconTheme: appBarIconTheme,
                centerTitle: effectiveCenterTitle,
                titleSpacing: widget.titleSpacing,
                excludeHeaderSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    IconThemeData appBarIconTheme,
    IconThemeData actionsIconTheme,
    TextStyle actionsTextStyle,
  ) {
    if (widget.actions == null) return const <Widget>[];

    final List<Widget> actionButtons = <Widget>[];
    for (final Widget action in widget.actions!) {
      if (action != null) {
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
