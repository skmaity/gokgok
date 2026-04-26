// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gokgok/core/theme/app_colors.dart';
// import 'package:gokgok/core/theme/app_sizes.dart';
// import 'package:gokgok/features/dash_board/pages/dash_board.dart';
// import 'package:gokgok/features/splash/providers/splash_provider.dart';
// import 'package:google_fonts/google_fonts.dart';

// class SplashScreen extends ConsumerStatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   ConsumerState<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends ConsumerState<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _firstGokFade;
//   late final Animation<double> _secondGokFade;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1600),
//     );

//     _firstGokFade = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
//     );

//     _secondGokFade = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.25, 0.6, curve: Curves.easeIn),
//     );

//     _controller.forward();
//     ref.read(splashProvider.notifier).moveToNextPage();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   TextStyle _logoStyle() {
//     return GoogleFonts.lobster(
//       fontSize: AppSizes.logoLarge,
//       color: AppColors.splashLime,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     ref.listen(splashProvider, (previous, next) {
//       if (next == SplashStatus.finish && mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const DashBoard()),
//         );
//       }
//     });

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: AppSizes.screenPadding),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   FadeTransition(
//                     opacity: _firstGokFade,
//                     child: Text("Gok", style: _logoStyle()),
//                   ),
//                   FadeTransition(
//                     opacity: _secondGokFade,
//                     child: Text("Gok", style: _logoStyle()),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
