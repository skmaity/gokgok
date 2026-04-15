import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/constants/app_assets.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';

class OnlineNowList extends StatelessWidget {
  const OnlineNowList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: 6,
        separatorBuilder: (context, index) => AppSizes.m.horizontalSpace,
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56.w,
                height: 56.w,
                child: Stack(
                  children: [
                    // Gradient border + avatar image
                    Container(
                      width: 56.w,
                      height: 56.w,
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryPink,
                            AppColors.accentOrange,
                          ],
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          image: DecorationImage(
                            image: AssetImage(AppAssets.profilePlaceholder),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Online green dot
                    Positioned(
                      right: 1.w,
                      bottom: 1.w,
                      child: Container(
                        height: 14.w,
                        width: 14.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF34D399),
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSizes.xs.verticalSpace,
              Text(
                "User ${index + 1}",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.dashboardOffWhite,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}
