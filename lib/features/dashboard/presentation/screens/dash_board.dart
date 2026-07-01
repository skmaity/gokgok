import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/features/dashboard/presentation/providers/navbar_provider.dart';
import 'package:gokgok/features/buzzer/presentation/screens/sounds_page.dart';
import 'package:gokgok/features/dashboard/presentation/widgets/bottom_nav_bar.dart';
import 'package:gokgok/features/chat/presentation/screens/chat_page.dart';
import 'package:gokgok/features/dashboard/presentation/screens/home_widget.dart';
import 'package:gokgok/features/dashboard/presentation/widgets/settings_widget.dart';

class DashBoard extends ConsumerWidget {
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Widget> pages = [
      HomeWidget(),
      ChatPage(),
      SoundsPage(),
      SettingsWidget(),
    ];
    if (kDebugMode) {
      debugPrint('dash board build');
    }

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BottomNavBar(),
      body: Consumer(
        builder: (context, ref, child) {
          final selectedIndex = ref.watch(navbarProvider);
          return pages[selectedIndex];
        },
      ),
    );
  }
}
