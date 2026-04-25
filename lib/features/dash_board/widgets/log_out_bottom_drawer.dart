import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/loginsignup/providers/auth_provider.dart';

class LogOutBottomDrawer extends ConsumerWidget {
  final BuildContext context;
  const LogOutBottomDrawer({super.key, required this.context});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(60),

            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSizes.xl.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(authProvider.notifier).logout();
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(100),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                            border: Border.all(color: Colors.pink, width: 0.5),
                          ),
                          child: Center(
                            child: Text(
                              'Logout?',
                              style: TextStyle(
                                color: Colors.white.withAlpha(255),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppSizes.l.horizontalSpace,
                    GestureDetector(
                      onTap: context.pop,
                      child: Container(
                        height: 60,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(100),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: Colors.white.withAlpha(255),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSizes.xl.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
