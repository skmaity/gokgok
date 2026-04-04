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
              AppSizes.m.verticalSpace,

              ClipPath(
                clipper: CustomClipPath(),
                child: Container(
                  height: 400.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    // border: Border.all(
                    //   width: 0.5.w,
                    //   color: AppColors.signupBoxBorder,
                    // ),
                  ),
                  child: Column(children: [
                      
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double h = size.height;
    double w = size.width;

    Path path = Path();
    path.moveTo(0, h * 0.2);
    path.lineTo(w * 0.5, 0);
    path.lineTo(w, h * 0.2);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
