import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommounSubmitBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const CommounSubmitBtn({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).extension<AppColors>()!.highlight;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 48.h,
        decoration: BoxDecoration(
          color: highlight,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  height: 22.h,
                  child: LoadingAnimationWidget.waveDots(
                    color: Colors.white,
                    size: 28.w,
                  ),
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
        ),
      ),
    );
  }
}
