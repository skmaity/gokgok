import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/widgets/common_shadow.dart';

/// The app's frosted pill surface (see bottom nav, back button, chat input):
/// white hairline border, soft shadow, backdrop blur and a translucent
/// navbarBg fill. Ripples on press when [onTap] is set.
class GlassPill extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double sigma;

  const GlassPill({super.key, required this.child, this.onTap, this.sigma = 8});

  @override
  Widget build(BuildContext context) {
    final navbarBg = Theme.of(context).extension<AppColors>()!.navbarBg;
    final radius = BorderRadius.circular(100);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: commonShadow,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Material(
            color: navbarBg.withAlpha(150),
            child: InkWell(onTap: onTap, child: child),
          ),
        ),
      ),
    );
  }
}
