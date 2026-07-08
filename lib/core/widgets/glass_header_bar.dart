import 'package:flutter/material.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/core/widgets/top_header_widget.dart';

/// [TopHeaderWidget] on an iOS-style fading tint (navbarBg -> transparent,
/// top -> bottom), sized for the Scaffold `appBar:` slot.
///
/// Pair with `extendBodyBehindAppBar: true`, wrap the page's scrollable in
/// [ProgressiveBlur] (height: [height] + status bar) so content blurs as it
/// slides under the bar, and give the scrollable the same top inset.
class GlassHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  /// Custom row shown instead of the default [TopHeaderWidget] (e.g. the
  /// home header). When used outside the appBar slot (in a Stack), size the
  /// bar yourself: [height] + status bar.
  final Widget? child;

  const GlassHeaderBar({
    super.key,
    this.title = '',
    this.onBack,
    this.trailing,
    this.child,
  });

  /// 48 = trailing IconButton min height (tallest row child).
  static double get height => 48 + AppSizes.sm * 2;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final navbarBg = Theme.of(context).extension<AppColors>()!.navbarBg;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            navbarBg.withAlpha(200),
            navbarBg.withAlpha(120),
            navbarBg.withAlpha(0),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child:
            child ??
            TopHeaderWidget(
              onPressed: onBack,
              title: title,
              trailing: trailing,
            ),
      ),
    );
  }
}
