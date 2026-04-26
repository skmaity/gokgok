import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gokgok/core/constants/app_assets.dart';
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

          // TextButton(
          //   onPressed: () {
          //     ref.read(themeProvider.notifier).switchToSunsetTheme();
          //   },
          //   child: Text("SunSet"),
          // ),
          // TextButton(
          //   onPressed: () {
          //     ref.read(themeProvider.notifier).switchToMintTheme();
          //   },
          //   child: Text("Mint"),
          // ),
          Container(height: 200.h, color: Colors.red.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.m),
            child: Container(
              height: 200.h,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          Container(height: 200.h, color: Colors.red.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.m),
            child: Container(
              height: 200.h,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          Container(height: 200.h, color: Colors.red.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.m),
            child: Container(
              height: 200.h,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          Container(height: 200.h, color: Colors.red.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.m),
            child: Container(
              height: 200.h,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          Container(height: 200.h, color: Colors.red.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.m),
            child: Container(
              height: 200.h,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          Container(height: 200.h, color: Colors.red.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.m),
            child: Container(
              height: 200.h,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          Container(height: 200.h, color: Colors.red.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.m),
            child: Container(
              height: 200.h,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
          Container(height: 200.h, color: Colors.red.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.m),
            child: Container(
              height: 200.h,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),

          settingsItem(svgIconPath: AppAssets.homeSmile, title: "Home"),
          settingsItem(svgIconPath: AppAssets.infoSquare, title: "About Us"),
        ],
      ),
    );
  }
}

Widget settingsItem({required String svgIconPath, required String title}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w),
    child: Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withAlpha(80), width: 1),
        ),
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
