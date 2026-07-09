import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const SubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).extension<AppColors>()!.highlight;

    return Semantics(
      button: true,
      enabled: !isLoading,
      label: label,
      child: Material(
        color: highlight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          onTap: isLoading ? null : onPressed,
          child: SizedBox(
            height: 48.h,
            width: double.infinity,
            child: Center(
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
          ),
        ),
      ),
    );
  }
}
