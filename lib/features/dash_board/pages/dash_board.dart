import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
                    // body
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
                              // style: TextStyle(color: Colors.white),
                              controller: searchController,
                            ),
                          ),
                          AppSizes.m.horizontalSpace,
                        ],
                      ),
                    ),
                    AppSizes.m.verticalSpace,
                    Row(
                      children: [
                        Text(
                          "online now",
                          style: TextStyle(
                            color: Colors.grey.withAlpha(140),
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    AppSizes.s.verticalSpace,
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
