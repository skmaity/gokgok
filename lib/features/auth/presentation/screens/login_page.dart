import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/features/auth/presentation/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gokgok/core/routing/app_routes.dart';
import 'package:gokgok/core/widgets/top_header_widget.dart';
import 'package:gokgok/core/constants/app_assets.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/auth/presentation/widgets/login_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, next) {
      if (next is AuthSuccess) {
        ref.read(authProvider.notifier).reset();
        context.go(AppRoutes.dashboard);
      } else if (next is AuthError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
        ref.read(authProvider.notifier).reset();
      }
    });

    final isLoading = ref.watch(authProvider) is AuthLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TopHeaderWidget(onPressed: () {}),
              AppSizes.m.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Log in",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    AppSizes.m.verticalSpace,
                    LoginTextField(
                      controller: emailTextController,
                      title: "Email",
                    ),
                    AppSizes.m.verticalSpace,
                    LoginTextField(
                      controller: passwordTextController,
                      title: "Password",
                    ),
                    AppSizes.m.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot password",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).extension<AppColors>()!.highlight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSizes.m.verticalSpace,
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        overlayColor: Colors.white,
                        backgroundColor: Theme.of(
                          context,
                        ).extension<AppColors>()!.highlight,
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12.r),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              ref
                                  .read(authProvider.notifier)
                                  .login(
                                    emailTextController.text.trim(),
                                    passwordTextController.text,
                                  );
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLoading ? "Submitting..." : "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSizes.xxl.verticalSpace,

                    Row(
                      children: [
                        Expanded(child: Divider()),
                        AppSizes.m.horizontalSpace,
                        Text("OR", style: TextStyle(color: Colors.grey)),
                        AppSizes.m.horizontalSpace,

                        Expanded(child: Divider()),
                      ],
                    ),
                    AppSizes.xxl.verticalSpace,

                    InkWell(
                      borderRadius: BorderRadius.circular(12),

                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 24,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppAssets.googleLogo,
                                height: 22.h,
                              ),
                              4.horizontalSpace,
                              Text(
                                "Google",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: AppSizes.m,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppSizes.l.verticalSpace,
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.fredoka(
                          fontSize: AppSizes.m,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(text: "Don't have an account? "),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () {
                                context.go(AppRoutes.signup);
                              },
                              child: Text(
                                "Sign up",
                                style: GoogleFonts.fredoka(
                                  fontSize: AppSizes.m,
                                  color: Theme.of(
                                    context,
                                  ).extension<AppColors>()!.highlight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
