import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gokgok/core/widgets/common_shadow.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';

class LoginTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  const LoginTextField({
    super.key,
    required this.title,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final navbarBg = Theme.of(context).extension<AppColors>()!.navbarBg;

    return Column(
      children: [
        Row(
          children: [Text(title, style: TextStyle(color: Colors.black54))],
        ),
        AppSizes.s.verticalSpace,

        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: navbarBg,
                  boxShadow: commonShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        validator: validator,
                        obscureText: obscureText,
                        keyboardType: keyboardType,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 14.h,
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
