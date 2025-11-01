import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void startWalkAnimation() {
    if (animationTimer.isActive) return;

    animationTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        walkFrame = walkFrame == 1 ? 2 : 1;
      });
    });
  }

  void stopWalkAnimation() {
    if (animationTimer.isActive) animationTimer.cancel();
    setState(() {
      playerState = 'idle';
      walkFrame = 1;
    });
  }

  void startRunAnimation() {
    if (animationTimer.isActive) return;

    animationTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        runFrame = runFrame == 1 ? 2 :1;
      });
    });
  }