import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gokgok/core/extentions/media_query_x.dart';
import 'package:gokgok/core/theme/app_sizes.dart';

/// Adds safe bottom padding so content never sits under the system UI
/// (gesture bar, 3-button nav bar or the keyboard).
///
/// The padding is composed of three parts:
/// * the system navigation-bar inset (only on Android with a 3-button nav bar),
/// * a base spacing — [bottomPadding] when given, otherwise [AppSizes.space20],
/// * the keyboard height, when [handelKeyboardHeight] is enabled.
class AppBottomPadding extends StatelessWidget {
  const AppBottomPadding({
    super.key,
    required this.child,
    this.bottomPadding,
    this.handelKeyboardHeight = false,
    this.showTopPadding = true,
  });

  final bool showTopPadding;

  /// Content to pad.
  final Widget child;

  /// Base bottom spacing. Falls back to [AppSizes.space20] when null.
  final double? bottomPadding;

  /// Whether to also lift content above the keyboard (`viewInsets.bottom`).
  final bool handelKeyboardHeight;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isGestureNav = mediaQuery.isGestureNav;

    final basePadding = isGestureNav ? bottomPadding ?? 0 : bottomPadding ?? 20;
    final keyboardHeight = handelKeyboardHeight
        ? mediaQuery.viewInsets.bottom
        : 0.0;

    // Only an Android 3-button nav bar needs the system inset added explicitly.
    final systemNavBarInset = Platform.isAndroid && !isGestureNav
        ? mediaQuery.padding.bottom
        : AppSizes.gestureNavThreshold;

    return Padding(
      padding: EdgeInsets.only(
        bottom: systemNavBarInset + basePadding + keyboardHeight,
        top: showTopPadding ? AppSizes.l : 0,
      ),
      child: child,
    );
  }
}
