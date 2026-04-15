import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gokgok/core/constants/app_assets.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<_NavBarItemData> _items = const [
    _NavBarItemData(title: 'Home', svgPath: AppAssets.homeSmile),
    _NavBarItemData(title: 'Add', svgPath: AppAssets.addIcon),
    _NavBarItemData(title: 'Settings', svgPath: AppAssets.settingsIcon),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          AppSizes.l.horizontalSpace,
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(color: AppColors.navbarBgColor),
                  height: 65.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.l),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < _items.length; i++)
                          _navbarItem(
                            title: _items[i].title,
                            svgPath: _items[i].svgPath,
                            isActive: _selectedIndex == i,
                            onTap: () => _handleItemTap(i),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          AppSizes.m.horizontalSpace,
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(color: AppColors.navbarBgColor),
                height: 65.h,
                width: 65.w,
                child: Padding(
                  padding: EdgeInsets.symmetric(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [SvgPicture.asset(AppAssets.soundWaveIcon)],
                  ),
                ),
              ),
            ),
          ),
          AppSizes.l.horizontalSpace,
        ],
      ),
    );
  }

  void _handleItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _navbarItem({
    required String title,
    required String svgPath,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color itemColor = isActive
        ? Colors.white
        : Colors.black.withAlpha(140);

    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          // color: isActive
          //     ? AppColors.primaryPink.withAlpha(26)
          //     : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              height: 24.h,
              colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
            ),
            2.verticalSpace,
          ],
        ),
      ),
    );
  }
}

class _NavBarItemData {
  const _NavBarItemData({required this.title, required this.svgPath});

  final String title;
  final String svgPath;
}
