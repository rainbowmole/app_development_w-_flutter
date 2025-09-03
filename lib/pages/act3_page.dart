import 'package:flutter/material.dart';

class ActivityPage4 extends StatelessWidget {
  final String title;

  const ActivityPage4({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(title)),

      body: const Center (
        child: Text('ilalim na pagunlad')
      ),
    );
  }
}