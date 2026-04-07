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
  double _dragPosition = 0.0; // 0.0 is bottom (false), 1.0 is top (true)
  bool _isToggled = false;

  void _handleDragUpdate(DragUpdateDetails details, double maxHeight) {
    // Notch height is 40% of total height (0.9h - 0.5h)
    double notchTop = maxHeight * 0.5;
    double notchBottom = maxHeight * 0.9;
    double buttonHeight = 50.h;
    double travelDistance = (notchBottom - notchTop) - buttonHeight;

    setState(() {
      _dragPosition -= details.delta.dy / travelDistance;
      _dragPosition = _dragPosition.clamp(0.0, 1.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      // Snap to ends
      if (_dragPosition > 0.5) {
        _dragPosition = 1.0;
        _isToggled = true;
      } else {
        _dragPosition = 0.0;
        _isToggled = false;
      }
    });
    debugPrint("Toggle State: $_isToggled");
  }

  @override
  Widget build(BuildContext context) {
    const double boxHeight = 400.0;

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
              LayoutBuilder(
                builder: (context, constraints) {
                  double w = constraints.maxWidth;
                  double h = boxHeight.h;
                  double notchTop = h * 0.5;
                  double notchBottom = h * 0.9;
                  double buttonHeight = 50.h;
                  double notchDepth = 45.w;

                  // Calculate vertical offset: 
                  // At 0.0, top is (notchBottom - buttonHeight)
                  // At 1.0, top is notchTop
                  double currentTop = notchBottom - buttonHeight - (_dragPosition * (notchBottom - notchTop - buttonHeight));

                  return Stack(
                    children: [
                      CustomPaint(
                        painter: SignupBoxPainter(),
                        child: Container(
                          height: h,
                          width: double.infinity,
                          padding: EdgeInsets.only(top: 80.h),
                          child: const Column(children: []),
                        ),
                      ),
                      Positioned(
                        top: currentTop,
                        right: 0,
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) => _handleDragUpdate(details, h),
                          onVerticalDragEnd: _handleDragEnd,
                          child: Container(
                            width: notchDepth,
                            height: buttonHeight,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPink,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(notchDepth),
                                bottomLeft: Radius.circular(notchDepth),
                              ),
                            ),
                            // child: Icon(
                            //   _isToggled ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            //   color: Colors.white,
                            // ),
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

class SignupBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double h = size.height;
    double w = size.width;
    double r = 30.r;

    // Notch calculations
    double notchDepth = 45.w; // Sync with widget
    double notchTop = h * 0.5;
    double notchBottom = h * 0.9;

    Paint paint = Paint()
      ..color = AppColors.primaryPink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.w
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    
    // Start bottom left (after the corner curve)
    path.moveTo(0, h - r);
    
    // Left side & Top-left corner
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    
    // Top side & Top-right corner
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r));
    
    // Right side down to notch - The "Pocket"
    path.lineTo(w, notchTop);
    path.arcToPoint(
      Offset(w - notchDepth, notchTop + notchDepth),
      radius: Radius.circular(notchDepth),
      clockwise: false,
    );
    path.lineTo(w - notchDepth, notchBottom - notchDepth);
    path.arcToPoint(Offset(w, notchBottom), radius: Radius.circular(notchDepth), clockwise: false);
    
    // Right side down to Bottom-right corner
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    
    // Bottom side & Bottom-left corner
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
