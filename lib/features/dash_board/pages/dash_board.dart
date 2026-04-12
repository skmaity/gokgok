import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:google_fonts/google_fonts.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
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
                                image: AssetImage("assets/images/download.jpg"),
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

                    // --- UPDATED SECTION STARTS HERE ---
                    // Online Profiles List
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(140),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPink.withAlpha(20),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // List Header "Online Now"
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.m,
                              vertical: AppSizes.s / 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Online now",
                                  style: TextStyle(
                                    color: Colors.grey.withAlpha(140),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Optional: Scroll indicator icon for the list below
                                // Icon(Icons.chevron_down_rounded, size: 18),
                              ],
                            ),
                          ),

                          // The List of Dummy Profiles
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 4, // Number of dummy profiles to show
                            separatorBuilder: (context, index) =>
                                AppSizes.s.verticalSpace,
                            itemBuilder: (context, index) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Profile Image Container with Gradient Border
                                  Padding(
                                    padding: EdgeInsets.all(2.5.w),
                                    child: Container(
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
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryPink
                                                .withAlpha(90),
                                            blurRadius: 20,
                                            offset: Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.avatarBorder,
                                            width: 1.5,
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(
                                              "assets/images/download.jpg",
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Online Status Dot (Absolute Positioning)
                                  Positioned(
                                    right: 1.w,
                                    bottom: 1.h,
                                    child: Container(
                                      height: 16.w,
                                      width: 16.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF34D399), // Green
                                        border: Border.all(
                                          color: AppColors.background,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(
                                              0xFF34D399,
                                            ).withAlpha(120),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // --- UPDATED SECTION ENDS HERE ---
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
