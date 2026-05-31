import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopHeaderWidgetTitleOnly extends StatelessWidget {
  final void Function()? onPressed;
  final double? padding;
  final String title;
  const TopHeaderWidgetTitleOnly({
    super.key,
    this.onPressed,
    required this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? 0, vertical: 6.h),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
