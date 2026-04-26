import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokgok/features/dash_board/providers/navbar_provider.dart';
import 'package:gokgok/features/dash_board/widgets/add_widget.dart';
import 'package:gokgok/features/dash_board/widgets/bottom_nav_bar.dart';
import 'package:gokgok/features/dash_board/widgets/home_widget.dart';
import 'package:gokgok/features/dash_board/widgets/settings_widget.dart';

class DashBoard extends ConsumerStatefulWidget {
  const DashBoard({super.key});

  @override
  ConsumerState<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends ConsumerState<DashBoard> {
  List<Widget> pages = [HomeWidget(), AddWidget(), SettingsWidget()];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navbarProvider);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomNavBar(),
      body: pages[selectedIndex],
    );
  }
}
