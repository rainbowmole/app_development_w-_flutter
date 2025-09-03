import 'package:flutter/material.dart';

class ActivityPage3 extends StatelessWidget {
  final String title;

  const ActivityPage3({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(title)),

      body: const Center (
        child: Text('development under')
      ),
    );
  }
}