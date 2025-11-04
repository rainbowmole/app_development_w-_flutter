import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class PlayerMovementControl {
  double playerX;
  double playerY;
  String direction;
  String state;

  bool isRunning = false;
  bool isJumping = false;
  Set<LogicalKeyboardKey> pressedKeys = {};
  Timer? idleTimer;

  final Function startWalkAnimation;
  final Function startRunAnimation;
  final Function stopWalkAnimation;
  final Function onUpdateUI;

  PlayerMovementControl({
    required this.playerX,
    required this.playerY,
    required this.direction,
    required this.state,
    required this.startWalkAnimation,
    required this.startRunAnimation,
    required this.stopWalkAnimation,
    required this.onUpdateUI,
  });

  Timer? moveTimer;
  
  void handleMovement() {
  double speed = isRunning ? 0.0095 : 0.006; //for ? running speed : walking speed
  double dx = 0;
  double dy = 0;

  if (pressedKeys.contains(LogicalKeyboardKey.keyA)) dx -= speed;
  if (pressedKeys.contains(LogicalKeyboardKey.keyD)) dx += speed;
  if (pressedKeys.contains(LogicalKeyboardKey.keyW)) dy -= speed;
  if (pressedKeys.contains(LogicalKeyboardKey.keyS)) dy += speed;

  if (dx != 0 || dy != 0) {
    playerX -= dx;
    playerY -= dy;

    playerX = playerX.clamp(-1.0, 1.0);
    playerY = playerY.clamp(-1.0, 1.0);

    if (dx > 0) direction = 'right';
    else if (dx < 0) direction = 'left';
    else if (dy < 0) direction = 'back';
    else if (dy > 0) direction = 'front';

    String newState = isRunning ? 'run' : 'walk';
    if (state != newState) {
      state = newState;
      if (isRunning) {
        startRunAnimation();
      } else {
        startWalkAnimation();
      }
    }

    scheduleIdleReset();
    onUpdateUI();
  }
}
  void onKeyDown(LogicalKeyboardKey key) {
    pressedKeys.add(key);
    moveTimer ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      handleMovement();
    });
  }

  void onKeyUp(LogicalKeyboardKey key) {
    pressedKeys.remove(key);
    if (pressedKeys.isEmpty) {
      moveTimer?.cancel();
      moveTimer = null;
    }
    scheduleIdleReset();
  }

  void setRunning(bool running) {
    isRunning = running;
    onUpdateUI();
  }

  void scheduleIdleReset() {
    idleTimer?.cancel();
    idleTimer = Timer(const Duration(milliseconds: 150), () {
      if (state == 'walk' || state == 'run') {
        stopWalkAnimation();
        state = 'idle';
        onUpdateUI();
      }
    });
  }

  void startJump(VoidCallback onFinish) {
    if (isJumping) return;
    isJumping = true;
    state = 'jump';
    onUpdateUI();

    Timer(const Duration(milliseconds: 500), () {
      isJumping = false;
      state = 'idle';
      onFinish();
      onUpdateUI();
    });
  }
}