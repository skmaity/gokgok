import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gokgok/core/constants/app_assets.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';

import 'package:gokgok/features/dash_board/providers/buzzer_provider.dart';
import 'package:gokgok/features/dash_board/providers/navbar_provider.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({super.key});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  // int _selectedIndex = 0;

  final List<_NavBarItemData> _items = const [
    _NavBarItemData(title: 'Home', svgPath: AppAssets.homeSmile),
    _NavBarItemData(title: 'Add', svgPath: AppAssets.addIcon),
    _NavBarItemData(title: 'Settings', svgPath: AppAssets.settingsIcon),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navbarProvider);
    print('nab bar build');
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: SafeArea(
        child: Row(
          children: [
            AppSizes.l.horizontalSpace,
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(buzzerProvider.notifier).buzzerClear();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusGeometry.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(4, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).extension<AppColors>()!.navbarBg.withAlpha(150),
                        ),
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
                                  isActive: selectedIndex == i,
                                  onTap: () => _handleItemTap(i),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AppSizes.m.horizontalSpace,
            GestureDetector(
              onTap: () async {
                ref.read(buzzerProvider.notifier).buzzerPressed();
                // await Supabase.instance.client.from("test").insert({
                //   'test_data': "shubha test data",
                // });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusGeometry.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: Offset(4, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).extension<AppColors>()!.navbarBg.withAlpha(150),
                      ),
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
              ),
            ),
            AppSizes.l.horizontalSpace,
          ],
        ),
      ),
    );
  }

  void _handleItemTap(int index) {
    ref.read(navbarProvider.notifier).state = index;
  }

  Widget _navbarItem({
    required String title,
    required String svgPath,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color itemColor = isActive
        ? Theme.of(context).extension<AppColors>()!.highlight
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
