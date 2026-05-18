import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/common/widgets/common_shadow.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';

class TopHeaderWidget extends StatelessWidget {
  final void Function()? onPressed;
  const TopHeaderWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final navbarBg = Theme.of(context).extension<AppColors>()!.navbarBg;

    return Row(
      children: [
        AppSizes.m.horizontalSpace,
        GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              // color: themeColor.withAlpha(40),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: commonShadow,
              borderRadius: BorderRadius.circular(100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(color: navbarBg.withAlpha(150)),

                  child: Center(
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
