import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/core/theme/theme_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("hello shubha how are you")],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(themeProvider.notifier).switchToSunsetTheme();
                },
                child: Text("sunset"),
              ),

              TextButton(
                onPressed: () {
                  ref.read(themeProvider.notifier).switchToMintTheme();
                },
                child: Text("mint"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
