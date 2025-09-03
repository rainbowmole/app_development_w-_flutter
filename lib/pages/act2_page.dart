import 'package:flutter/material.dart';

class ActivityPage2 extends StatelessWidget {
  final String title;

  const ActivityPage2({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text(title)),

      body: const Center (
        child: Text('pagunlad sa ilalim')
      ),
    );
  }
}