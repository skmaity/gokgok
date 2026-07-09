import 'package:flutter/widgets.dart';
import 'package:gokgok/core/theme/app_sizes.dart';

/// Navigation-inset helpers derived from [MediaQueryData].
extension MediaQueryX on MediaQueryData {
  /// Whether the device uses gesture navigation (thin home indicator) rather
  /// than a 3-button nav bar.
  ///
  /// Inferred from the bottom safe-area inset: a gesture bar reserves only a
  /// small inset, while a 3-button bar reserves a taller one.
  bool get isGestureNav => viewPadding.bottom < AppSizes.gestureNavThreshold;
}
