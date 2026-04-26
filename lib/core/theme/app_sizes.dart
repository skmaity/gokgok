import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSizes {
  AppSizes._();

  // Base spacing scale
  static double get xs => 4.w;
  static double get s => 8.w;
  static double get m => 16.w;
  static double get l => 24.w;
  static double get xl => 32.w;
  static double get xxl => 40.w;

  // Layout
  static double get screenPadding => 24.w;
  static double get largeBlobSize => 300.w;
  static double get mediumBlobSize => 220.w;

  // Typography
  static double get logoLarge => 60.sp;
  static double get logoMedium => 30.sp;

  // Components
  static double get avatarSize => 40.w;
  static double get iconSizeSmall => 16.w;
  static double get iconSizeMedium => 24.w;
  static double get iconSizeLarge => 32.w;
  static double get buttonHeight => 52.h;
  static double get inputHeight => 52.h;

  // Border radius
  static double get radiusSmall => 12.r;
  static double get radiusMedium => 20.r;
  static double get radiusLarge => 32.r;
  static double get radiusCircular => 100.r;
  static double get radiusFull => 200.r;
}
