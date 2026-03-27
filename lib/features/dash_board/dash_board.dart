import 'package:flutter/material.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GokGok')),
      body: const Center(
        child: Text(
          'App launched successfully',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
