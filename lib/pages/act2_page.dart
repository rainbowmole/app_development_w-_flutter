import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dungeon_game/background_grid_tiles.dart';

class ActivityPage2 extends StatefulWidget {
  const ActivityPage2({super.key});

  @override
  _AvoidGameState createState() => _AvoidGameState();
}

class _AvoidGameState extends State<ActivityPage2> {
  int health = 3;

  double playerWidth = 0.25; 
  double playerHeight = 0.25;

  double objectWidth = 0.15;
  double objectHeight = 0.15;

  final double playerHitboxWidth = 250 * 0.4;
  final double playerHitboxHeight = 250 * 0.4;

  final double objectHitboxWidth = 150 * 0.6;
  final double objectHitboxHeight = 150 * 0.6;

  double worldOffsetX = 0;
  double worldOffsetY = 0;

  bool checkCollision({
    required double x1,
    required double y1,
    required double w1,
    required double h1,
    required double x2,
    required double y2,
    required double w2,
    required double h2,
  }) {
    return !(x1 + w1 < x2 || x1 > x2 + w2 || y1 + h1 < y2 || y1 > y2 + h2);
  }

  String playerDirection = 'front'; //front(down), back(up), left, right
  String playerState = 'idle'; // idle, running, jumping, walking, dodge/roll, 

  double objectX = Random().nextDouble() * 2 - 1;
  double objectY = -1;

  int coin = 0;
  bool gameOver = false;
  late Timer gameTimer;
  String objectType = 'avoid';

  int walkFrame = 1;
  late Timer animationTimer =Timer(Duration.zero, () {});
  bool isJumping = false;
  int runFrame = 1;
  bool isRunning = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void startGame() {
    setState(() {
      health = 3;
      coin = 0;
      gameOver = false;
      objectY = -1;
      objectX = Random().nextDouble() * 2 - 1;
      objectType = Random().nextBool() ? 'avoid' : 'collect';
      playerState = 'idle';
      
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    if (gameOver) return; 

    setState(() {
      objectY += 0.03;

      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      // Convert to alignment units (-1 to 1)
      double playerWidth = playerHitboxWidth / screenWidth;
      double playerHeight = playerHitboxHeight / screenHeight;

      double objectWidth = objectHitboxWidth / screenWidth;
      double objectHeight = objectHitboxHeight / screenHeight;

      double adjustedObjectX = objectX + worldOffsetX;
      double adjustedObjectY = objectY + worldOffsetY;

      if (checkCollision(
          x1: 0 - playerWidth / 2,
          y1: 0 - playerHeight / 2,
          w1: playerWidth,
          h1: playerHeight,
          x2: adjustedObjectX - objectWidth / 2,
          y2: adjustedObjectY - objectHeight / 2,
          w2: objectWidth,
          h2: objectHeight,
        )) {
        if (objectType == 'avoid') {
          health -= 1;
          if (health == 0){
            gameOver = true;
            gameTimer.cancel();
            return;
          } else {
            resetObject();
          }
        } else if (objectType == 'collect') {
          coin += 1;
          resetObject();
        }
      }

      if (objectY > 1) {
        resetObject();
      }
    });
  }

  void resetObject() {
    objectY = -1;
    objectX = Random().nextDouble() * 2 - 1;
    objectType = Random().nextBool() ? 'avoid' : 'collect';
  }

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

  void movePlayerLeftRight(double direction) {
    setState(() {
      worldOffsetX += direction;

      worldOffsetX = worldOffsetX.clamp(-1.0, 1.0);

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
      worldOffsetY += direction;
      
      worldOffsetY = worldOffsetY.clamp(-1.0, 1.0);

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

  @override
  void dispose() {
    if (gameTimer.isActive) gameTimer.cancel();
    idleTimer?.cancel();
    super.dispose();
  }

  final Set<LogicalKeyboardKey> movementKeys = {
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyS,
  };

  Timer? idleTimer;

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

  final Set<LogicalKeyboardKey> pressedKeys = {};

  void clampWorldOffset() {
    final screenSize = MediaQuery.of(context).size;
    final double gridWidth = screenSize.width;
    final double gridHeight = screenSize.height;

    // Assuming grid is centered and spans full screen
    double maxOffsetX = 1.0; // alignment units
    double maxOffsetY = 1.0;

    worldOffsetX = worldOffsetX.clamp(-maxOffsetX, maxOffsetX);
    worldOffsetY = worldOffsetY.clamp(-maxOffsetY, maxOffsetY);
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
        worldOffsetX +- dx;
        worldOffsetY +- dy;

        clampWorldOffset();

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

  @override
  Widget build(BuildContext context) {

    double playerHitboxWidth = 250 * 0.4;
    double playerHitboxHeight = 250 * 0.4;

    double objectHitboxWidth = 150 * 0.6;
    double objectHitboxHeight = 150 * 0.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dodging Game Sample")
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (event){
          if (event is RawKeyDownEvent) {
            pressedKeys.add(event.logicalKey);
            handleMovement();
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft) {
              setState(() {
                isRunning = true;
              });
            }

            double speed = isRunning ? 0.02 : 0.02;

            if (event.logicalKey == LogicalKeyboardKey.keyA) {
              movePlayerLeftRight(-speed-(-0.015));
            } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
              movePlayerLeftRight(speed-0.015);
            } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
              movePlayerUpDown(-speed);
            } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
              movePlayerUpDown(speed);
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              setState(() {
                playerState = 'jump';
                isJumping = true;
              });

              Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  playerState = 'idle';
                  isJumping = false;
                });
              });
            } else if (event.logicalKey == LogicalKeyboardKey.enter){
              startGame();
            }
          } else if (event is RawKeyUpEvent) {
            if (movementKeys.contains(event.logicalKey)) {
              pressedKeys.remove(event.logicalKey);
              scheduleIdleReset();
            }

            if (event.logicalKey == LogicalKeyboardKey.shiftLeft) {
              setState(() {
                isRunning = false;
              });
            }
          }
        },

        child: Stack(
        children: [
          Image.asset(
            'assets/map/background_expirement2.jpg',
            fit: BoxFit.none,
            filterQuality: FilterQuality.none,
          ),

          const GridBackground(cellSize: 32),

          Align(
            alignment: Alignment(objectX, objectY),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                'dodge/$objectType.png',
                width: 150,
                height: 150,
                ),
                Container(
                  width: objectHitboxWidth,
                  height: objectHitboxHeight,
                  decoration: BoxDecoration(border: Border.all(color: Colors.red)),
                ),
              ],
            ) 
          ),
          
          Align(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                playerState == 'idle' 
                  ? 'assets/player/${playerDirection}_idle.gif'
                : playerState == 'walk' 
                  ? 'assets/player/player_${playerDirection}_walk${walkFrame}.png'
                : playerState == 'jump' 
                  ? 'assets/player/${playerDirection}_jump.gif'
                : playerState == 'run' 
                  ? 'assets/player/player_${playerDirection}_run${runFrame}.png' 
                : 'assets/player/player_$playerDirection.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
                ),
                Container(
                  width: playerHitboxWidth, 
                  height: playerHitboxHeight, 
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                  ),
                ),
              ]
            ),
          ),
          

          Positioned(
            top: 50,
            left: 20,
            child: Text(
              'Coin: $coin',
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),

          Positioned(
            top: 90,
            left: 20,
            child: Text(
              'Health: $health',
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),

          if (gameOver)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Game Over!',
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Coin: $coin',
                      style:
                          const TextStyle(fontSize: 24, color: Colors.white)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: startGame,
                    child: const Text('Play Again'),
                  ),
                ],
              ),
            ),

          if (!gameOver && coin == 0)
            Center(
              child: ElevatedButton(
                onPressed: startGame,
                child: const Text('Press ENTER to Start Game'),
              ),
            ),
        ],
      ),
      ),

      bottomNavigationBar: Container(
        color: Colors.black87,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('PRESS A TO MOVE LEFT, PRESS D TO MOVE RIGHT')
          ],
        ),
      ),
    );
  }
}
