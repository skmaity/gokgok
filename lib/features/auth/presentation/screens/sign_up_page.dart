import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/widgets/top_header_widget.dart';
import 'package:gokgok/core/constants/app_assets.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/auth/presentation/providers/auth_provider.dart';
import 'package:gokgok/features/auth/presentation/widgets/login_text_field.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController confirmPasswordTextController =
      TextEditingController();

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty';
    }

    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != passwordTextController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _submitSignUp() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ref
        .read(authProvider.notifier)
        .signUp(emailTextController.text.trim(), passwordTextController.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, next) {
      if (next is AuthSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign up successful')));
        ref.read(authProvider.notifier).reset();
        context.pop();
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
              TopHeaderWidget(
                onPressed: () {
                  context.pop();
                },
              ),
              AppSizes.m.verticalSpace,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Sign up",
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
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      AppSizes.m.verticalSpace,
                      LoginTextField(
                        controller: passwordTextController,
                        title: "Password",
                        validator: _validatePassword,
                        obscureText: true,
                      ),
                      AppSizes.m.verticalSpace,
                      LoginTextField(
                        controller: confirmPasswordTextController,
                        title: "Confirm password",
                        validator: _validateConfirmPassword,
                        obscureText: true,
                      ),
                      AppSizes.xxl.verticalSpace,
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
                        onPressed: isLoading ? null : _submitSignUp,
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
                            TextSpan(text: "Already have an account? "),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () {
                                  context.pop();
                                },
                                child: Text(
                                  "Log in",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
