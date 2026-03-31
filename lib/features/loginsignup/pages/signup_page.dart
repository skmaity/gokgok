import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    final glassRadius = BorderRadius.circular(AppSizes.radiusFull);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'GokGok',
                    style: GoogleFonts.lobster(
                      fontSize: AppSizes.logoMedium,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ],
              ),

              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200.h,
                    width: 65.w,
                    decoration: BoxDecoration(
                      borderRadius: glassRadius,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPink.withAlpha(90),
                          blurRadius: 50,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.white.withAlpha(35),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: glassRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                      child: Container(
                        height: 200.h,
                        width: 65.w,
                        decoration: BoxDecoration(
                          borderRadius: glassRadius,
                          border: Border.all(
                            color: Colors.white.withAlpha(90),
                            width: 1.2,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withAlpha(80),
                              AppColors.primaryPink.withAlpha(70),
                              Colors.white.withAlpha(25),
                            ],
                          ),
                        ),
                        child: Column(children: []),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
