import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/common/widgets/custom_text_form_field.dart';
import 'package:gokgok/common/widgets/submit_button.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/loginsignup/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0; // 0.0 = bottom (sign up), 1.0 = top (login)

  late AnimationController _snapController;
  late Animation<double> _snapAnim;

  // Sign Up form
  final _signUpFormKey = GlobalKey<FormState>();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpPasswordCtrl = TextEditingController();
  final _signUpEmailFocus = FocusNode();
  final _signUpPasswordFocus = FocusNode();

  // Login form
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _loginEmailFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _snapAnim = const AlwaysStoppedAnimation(0.0);
    _snapController.addListener(
      () => setState(() => _dragPosition = _snapAnim.value),
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPasswordCtrl.dispose();
    _signUpEmailFocus.dispose();
    _signUpPasswordFocus.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details, double maxHeight) {
    double notchTop = maxHeight * 0.5;
    double notchBottom = maxHeight * 0.9;
    double buttonHeight = 50.h;
    double travelDistance = (notchBottom - notchTop) - buttonHeight;
    setState(() {
      _dragPosition = (_dragPosition - details.delta.dy / travelDistance).clamp(
        0.0,
        1.0,
      );
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final double target = _dragPosition > 0.5 ? 1.0 : 0.0;

    _snapAnim = Tween<double>(begin: _dragPosition, end: target).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.elasticOut),
    );
    _snapController
      ..reset()
      ..forward();
  }

  void _onSignUp() {
    if (!(_signUpFormKey.currentState?.validate() ?? false)) return;
    ref
        .read(authProvider.notifier)
        .signUp(_signUpEmailCtrl.text, _signUpPasswordCtrl.text);
  }

  void _onLogin() {
    if (!(_loginFormKey.currentState?.validate() ?? false)) return;
    ref
        .read(authProvider.notifier)
        .login(_loginEmailCtrl.text, _loginPasswordCtrl.text);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email cannot be empty';
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    if (value.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Need one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Need one number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, next) {
      if (next is AuthSuccess) {
        ref.read(authProvider.notifier).reset();
        context.go('/dashboard');
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
        ref.read(authProvider.notifier).reset();
      }
    });

    final isLoading = ref.watch(authProvider) is AuthLoading;

    const double boxHeight = 400.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSizes.m.verticalSpace,
              LayoutBuilder(
                builder: (context, constraints) {
                  double h = boxHeight.h;
                  double notchTop = h * 0.6;
                  double notchBottom = h * 0.88;
                  double buttonHeight = 70.h;
                  double notchDepth = 27.9.w;

                  double currentTop =
                      notchBottom -
                      buttonHeight -
                      (_dragPosition * (notchBottom - notchTop - buttonHeight));

                  final double formSlide = (_dragPosition - 1) * h;

                  return Stack(
                    children: [
                      // ── Background box ──────────────────────────────────
                      CustomPaint(
                        painter: SignupBoxPainter(),
                        child: SizedBox(height: h, width: double.infinity),
                      ),

                      // ── Scrolling forms ─────────────────────────────────
                      Positioned.fill(
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.topLeft,
                            minHeight: 0,
                            maxHeight: double.infinity,
                            child: Transform.translate(
                              offset: Offset(0, formSlide),
                              child: Column(
                                children: [
                                  // Login form — top slot
                                  SizedBox(
                                    height: h,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.m,
                                        vertical: AppSizes.l,
                                      ),
                                      child: _LoginForm(
                                        formKey: _loginFormKey,
                                        emailCtrl: _loginEmailCtrl,
                                        passwordCtrl: _loginPasswordCtrl,
                                        emailFocus: _loginEmailFocus,
                                        passwordFocus: _loginPasswordFocus,
                                        validateEmail: _validateEmail,
                                        validatePassword: _validatePassword,
                                        onSubmit: _onLogin,
                                        isLoading: isLoading,
                                      ),
                                    ),
                                  ),
                                  // Sign up form — bottom slot
                                  SizedBox(
                                    height: h,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.m,
                                        vertical: AppSizes.l,
                                      ),
                                      child: _SignUpForm(
                                        formKey: _signUpFormKey,
                                        emailCtrl: _signUpEmailCtrl,
                                        passwordCtrl: _signUpPasswordCtrl,
                                        emailFocus: _signUpEmailFocus,
                                        passwordFocus: _signUpPasswordFocus,
                                        validateEmail: _validateEmail,
                                        validatePassword: _validatePassword,
                                        onSubmit: _onSignUp,
                                        isLoading: isLoading,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Notch drag button ───────────────────────────────
                      Positioned(
                        top: currentTop,
                        right: 0,
                        child: GestureDetector(
                          onVerticalDragUpdate: isLoading
                              ? null
                              : (d) => _handleDragUpdate(d, h),
                          onVerticalDragEnd: isLoading ? null : _handleDragEnd,
                          child: Container(
                            width: notchDepth,
                            height: buttonHeight,
                            decoration: BoxDecoration(
                              color: Colors.brown,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(notchDepth),
                                bottomLeft: Radius.circular(notchDepth),
                              ),
                            ),
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
      ),
    );
  }
}

// ── Sign Up Form ──────────────────────────────────────────────────────────────

class _SignUpForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _SignUpForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.emailFocus,
    required this.passwordFocus,
    required this.validateEmail,
    required this.validatePassword,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          AppSizes.xs.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'create your account',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11.sp,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          AppSizes.m.verticalSpace,
          CustomTextFormField(
            hintText: 'email',
            controller: emailCtrl,
            focusNode: emailFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(passwordFocus),
          ),
          AppSizes.s.verticalSpace,
          CustomTextFormField(
            hintText: 'password',
            obscureText: true,
            controller: passwordCtrl,
            focusNode: passwordFocus,
            textInputAction: TextInputAction.done,
            validator: validatePassword,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          AppSizes.l.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SubmitButton(
              label: 'SIGN UP',
              onPressed: onSubmit,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Login Form ────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.emailFocus,
    required this.passwordFocus,
    required this.validateEmail,
    required this.validatePassword,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          AppSizes.xs.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'welcome back',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11.sp,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          AppSizes.m.verticalSpace,
          CustomTextFormField(
            hintText: 'email',
            controller: emailCtrl,
            focusNode: emailFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(passwordFocus),
          ),
          AppSizes.s.verticalSpace,
          CustomTextFormField(
            hintText: 'password',
            obscureText: true,
            controller: passwordCtrl,
            focusNode: passwordFocus,
            textInputAction: TextInputAction.done,
            validator: validatePassword,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          AppSizes.xs.verticalSpace,
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: GestureDetector(
                onTap: () => debugPrint('Forgot password tapped'),
                child: Text(
                  'forgot password?',
                  style: TextStyle(
                    color: AppColors.primaryPink.withValues(alpha: 0.7),
                    fontSize: 11.sp,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          AppSizes.m.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SubmitButton(
              label: 'LOG IN',
              onPressed: onSubmit,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class SignupBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double h = size.height;
    double w = size.width;
    double r = 30.r;

    double notchDepth = 35.w;
    double notchTop = h * 0.58;
    double notchBottom = h * 0.9;

    Paint paint = Paint()
      ..color = AppColors.avatarBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.w
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    Path path = Path();

    path.moveTo(0, h - r);
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r));

    path.lineTo(w, notchTop);
    path.arcToPoint(
      Offset(w - notchDepth, notchTop + notchDepth),
      radius: Radius.circular(notchDepth),
      clockwise: false,
    );
    path.lineTo(w - notchDepth, notchBottom - notchDepth);
    path.arcToPoint(
      Offset(w, notchBottom),
      radius: Radius.circular(notchDepth),
      clockwise: false,
    );

    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
