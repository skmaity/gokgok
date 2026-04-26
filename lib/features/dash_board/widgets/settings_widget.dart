import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/core/theme/theme_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gokgok/core/constants/app_assets.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
// import 'package:gokgok/core/theme/theme_provider.dart';

class SettingsWidget extends ConsumerWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MediaQuery.of(context).viewPadding.top.verticalSpace,
          AppSizes.s.verticalSpace,
          Row(
            children: [
              AppSizes.l.horizontalSpace,

              Text(
                "Settings",
                style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          AppSizes.l.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.m),
            child: Container(
              height: 200.h,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          section('Theme'),
          AppSizes.sm.verticalSpace,
          Row(
            children: [
              AppSizes.l.horizontalSpace,
              Expanded(child: themeCardMint(context, ref)),
              AppSizes.m.horizontalSpace,

              Expanded(child: themeCardSunSet(context, ref)),
              AppSizes.l.horizontalSpace,
            ],
          ),
          AppSizes.l.verticalSpace,
          section('Options'),

          settingsItem(svgIconPath: AppAssets.homeSmile, title: "Home"),
          settingsItem(
            svgIconPath: AppAssets.infoSquare,
            title: "About Us",
            isLast: true,
          ),
          AppSizes.xl.verticalSpace,
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '—';
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "App Version $version",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).extension<AppColors>()!.highlight,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget themeCardSunSet(BuildContext context, WidgetRef ref) {
  return GestureDetector(
    onTap: () {
      ref.read(themeProvider.notifier).switchToSunsetTheme();
    },
    child: Container(
      // width: 100,
      // height: 80,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).extension<AppColors>()!.navbarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(4, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 24.h,
                width: 24.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffe8e8df)),
                  color: Color(0xfffbf3e8),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              6.horizontalSpace,
              Container(
                height: 24.h,
                width: 24.w,
                decoration: BoxDecoration(
                  color: Color(0xffe85d4a),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              6.horizontalSpace,
              Container(
                height: 24.h,
                width: 24.w,
                decoration: BoxDecoration(
                  color: Color(0xffe85d4a),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          AppSizes.s.verticalSpace,
          Row(
            children: [Text("SunSet", style: TextStyle(fontSize: AppSizes.m))],
          ),
          Row(
            children: [
              Text(
                "warm + cozy",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget themeCardMint(BuildContext context, WidgetRef ref) {
  return GestureDetector(
    onTap: () {
      ref.read(themeProvider.notifier).switchToMintTheme();
    },
    child: Container(
      // width: 100,
      // height: 80,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).extension<AppColors>()!.navbarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(4, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 24.h,
                width: 24.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffe8e8df)),
                  color: Color(0xfffdfdf9),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              6.horizontalSpace,
              Container(
                height: 24.h,
                width: 24.w,
                decoration: BoxDecoration(
                  color: Color(0xff06d6a0),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              6.horizontalSpace,
              Container(
                height: 24.h,
                width: 24.w,
                decoration: BoxDecoration(
                  color: Color(0xff118ab2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          AppSizes.s.verticalSpace,
          Row(
            children: [Text("Mint", style: TextStyle(fontSize: AppSizes.m))],
          ),
          Row(
            children: [
              Text(
                "fresh and cool",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget section(String title) {
  return Row(
    children: [
      24.horizontalSpace,
      Text(
        title,
        style: TextStyle(fontSize: AppSizes.ml, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

Widget settingsItem({
  required String svgIconPath,
  required String title,
  bool? isLast,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w),
    child: Container(
      decoration: BoxDecoration(
        border: !(isLast != null && isLast == true)
            ? Border(
                bottom: BorderSide(color: Colors.grey.withAlpha(80), width: 1),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.l),
        child: Row(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  height: 24,
                  svgIconPath,
                  colorFilter: ColorFilter.mode(
                    Colors.black87,
                    BlendMode.srcIn,
                  ),
                ),
                AppSizes.m.horizontalSpace,
                Text(
                  title,
                  style: TextStyle(color: Colors.black87, fontSize: 14.sp),
                ),
              ],
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ],
        ),
      ),
    ),
  );
}
