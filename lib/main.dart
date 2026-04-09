import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/features/dash_board/pages/dash_board.dart';
import 'package:gokgok/features/loginsignup/pages/signup_page.dart';
import 'package:gokgok/features/splash/bloc/splash_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _route = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => SignupPage(),

      routes: [
        GoRoute(path: 'dashboard', builder: (context, state) => DashBoard()),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => SplashBloc())],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) {
          return MaterialApp.router(
            routerConfig: _route,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              textTheme: GoogleFonts.fredokaTextTheme(),
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primaryPink,
              ),
              // fontFamily: 'storyscript',
            ),
           
          );
        },
      
      ),
    );
  }
}
