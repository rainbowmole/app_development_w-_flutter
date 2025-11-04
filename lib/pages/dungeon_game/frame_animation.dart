import 'dart:async';
import 'package:flutter/material.dart';

class FrameAnimation with ChangeNotifier {
  int walkFrame = 1;
  int runFrame = 1;
  Timer? _animationTimer;

  void startWalkAnimation() {
    _startLoop(() {
      walkFrame = (walkFrame == 1) ? 2 : 1;
    }, speedMs: 200);
  }

  void startRunAnimation() {
    _startLoop(() {
      runFrame = (runFrame == 1) ? 2 : 1;
    }, speedMs: 120); // faster run speed
  }

  void stopWalkAnimation() {
    _animationTimer?.cancel();
    walkFrame = 1;
    runFrame = 1;
    notifyListeners();
  }

  void _startLoop(VoidCallback onFrameChange, {int speedMs = 200}) {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(Duration(milliseconds: speedMs), (_) {
      onFrameChange();
      notifyListeners();
    });
  }

  void disposeAnimation() {
    _animationTimer?.cancel();
  }
}