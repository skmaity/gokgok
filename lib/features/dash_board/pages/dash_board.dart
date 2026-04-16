import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/constants/app_assets.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/dash_board/providers/buzzer_provider.dart';
import 'package:gokgok/features/dash_board/widgets/bottom_nav_bar.dart';
import 'package:gokgok/features/dash_board/widgets/online_now_list.dart';
import 'package:google_fonts/google_fonts.dart';

class DashBoard extends ConsumerStatefulWidget {
  const DashBoard({super.key});

  @override
  ConsumerState<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends ConsumerState<DashBoard> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background blobs
            Positioned(
              left: -20,
              top: -30,
              child: Container(
                height: AppSizes.largeBlobSize,
                width: AppSizes.largeBlobSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  color: AppColors.primaryPink.withAlpha(85),
                ),
              ),
            ),

            // Glassmorphism overlay
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(color: AppColors.glassOverlay),
                ),
              ),
            ),

            // main body
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.screenPadding,
                ),
                child: Column(
                  children: [
                    // header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GokGok',
                          style: GoogleFonts.lobster(
                            fontSize: AppSizes.logoMedium,
                            color: AppColors.primaryPink,
                          ),
                        ),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusCircular,
                          ),
                          child: SizedBox(
                            height: AppSizes.avatarSize,
                            width: AppSizes.avatarSize,
                            child: Center(
                              child: Image(
                                image: AssetImage(AppAssets.profilePlaceholder),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSizes.m.verticalSpace,
                    // body (Search bar)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(140),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      child: Row(
                        children: [
                          AppSizes.m.horizontalSpace,
                          Icon(Icons.search_rounded),
                          AppSizes.s.horizontalSpace,

                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: "find squads or people...",
                                border: InputBorder.none,
                              ),
                              controller: searchController,
                            ),
                          ),
                          AppSizes.m.horizontalSpace,
                        ],
                      ),
                    ),
                    AppSizes.m.verticalSpace,

                    // Online Now section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Online now",
                          style: TextStyle(
                            color: AppColors.dashboardOffWhite,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSizes.s.verticalSpace,
                        OnlineNowList(),
                        AppSizes.s.verticalSpace,

                        Consumer(
                          builder: (context, ref, child) {
                            final buzzer = ref.watch(buzzerProvider);
                            return Text(
                              buzzer,
                              style: TextStyle(
                                color: AppColors.dashboardOffWhite,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // bottom nav bar
            Positioned(bottom: 10, right: 0, left: 0, child: BottomNavBar()),
          ],
        ),
      ),
    );
  }
}
