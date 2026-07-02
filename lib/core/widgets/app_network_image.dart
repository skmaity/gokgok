import 'package:flutter/material.dart';

import 'package:gokgok/core/constants/app_assets.dart';

/// Network image with a fallback for null/empty URLs and load errors.
// ponytail: wraps Image.network (in-memory cache only); swap the body for
// CachedNetworkImage if avatars re-downloading after app restart becomes a problem.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.size,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
  });

  final String? url;

  /// Width and height (square). Omit to size from the parent.
  final double? size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Shown when [url] is null/empty or fails to load. Defaults to the
  /// profile placeholder asset.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final placeholder =
        fallback ?? Image.asset(AppAssets.profilePlaceholder, fit: fit);

    Widget image = (url == null || url!.isEmpty)
        ? placeholder
        : Image.network(url!, fit: fit, errorBuilder: (_, _, _) => placeholder);

    if (size != null) {
      image = SizedBox(width: size, height: size, child: image);
    }
    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
