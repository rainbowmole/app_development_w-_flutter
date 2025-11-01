String PlayerMovementControl = """
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerMovementControl {
  final double playerX;
  final double playerY;
  final String playerDirection;
  final String playerState;
}
 
 
 void movePlayerLeftRight(double direction) {
    setState(() {
      playerX += direction;
      if (playerX > 1) playerX = 1;
      if (playerX < -1) playerX = -1;

      playerDirection = direction < 0 ? 'left' : 'right';
      playerState = isRunning ? 'run' : 'walk';

      if (isRunning) {
          startRunAnimation();
        } else {
          startWalkAnimation();
        }

        scheduleIdleReset();
    });
  }

  void movePlayerUpDown(double direction) {
    setState(() {
      playerY += direction;
      if (playerY > 1) playerY = 1;
      if (playerY < -1) playerY = -1;

      playerDirection = direction < 0 ? 'back' : 'front';
      playerState = isRunning ? 'run' : 'walk';

      if (isRunning) {
          startRunAnimation();
        } else {
          startWalkAnimation();
        }

        scheduleIdleReset();
    });
  }

   void scheduleIdleReset() {
    idleTimer?.cancel();
    idleTimer = Timer(const Duration(milliseconds: 150), () {
      if (playerState == 'walk' || playerState == 'run') {
        stopWalkAnimation();
        setState(() {
          playerState = 'idle';
          walkFrame = 1;
          runFrame = 1;
        });
      }
    });
  }

  void handleMovement() {
    double speed = isRunning ? 0.045 : 0.015;
    double dx = 0;
    double dy = 0;

    if (pressedKeys.contains(LogicalKeyboardKey.keyA)) dx -= speed;
    if (pressedKeys.contains(LogicalKeyboardKey.keyD)) dx += speed;
    if (pressedKeys.contains(LogicalKeyboardKey.keyW)) dy -= speed;
    if (pressedKeys.contains(LogicalKeyboardKey.keyS)) dy += speed;

    if (dx != 0 || dy != 0) {
      setState(() {
        playerX += dx;
        playerY += dy;
        playerX = playerX.clamp(-1.0, 1.0);
        playerY = playerY.clamp(-1.0, 1.0);

        // Determine direction
        if (dx > 0 && dy < 0) playerDirection = 'right';
        else if (dx < 0 && dy < 0) playerDirection = 'left';
        else if (dx > 0 && dy > 0) playerDirection = 'right';
        else if (dx < 0 && dy > 0) playerDirection = 'left';
        else if (dx > 0) playerDirection = 'right';
        else if (dx < 0) playerDirection = 'left';
        else if (dy < 0) playerDirection = 'back';
        else if (dy > 0) playerDirection = 'front';

        playerState = isRunning ? 'run' : 'walk';
        if (isRunning) {
          startRunAnimation();
        } else {
          startWalkAnimation();
        }

        scheduleIdleReset();
      });
    }
  }
""";