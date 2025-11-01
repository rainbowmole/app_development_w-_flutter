import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActivityPage2 extends StatefulWidget {
  const ActivityPage2({super.key});

  @override
  _AvoidGameState createState() => _AvoidGameState();
}

class _AvoidGameState extends State<ActivityPage2> {
  int health = 3;

  double playerX = 0;
  double playerY = -1;

  String playerDirection = 'front'; //front(down), back(up), left, right
  String playerState = 'idle'; // idle, running, jumping, walking, dodge/roll, 

  double objectX = Random().nextDouble() * 2 - 1;
  double objectY = -1;

  int score = 0;
  bool gameOver = false;
  late Timer gameTimer;
  String objectType = 'avoid';

  int walkFrame = 1;
  late Timer animationTimer;
  bool isJumping = false;

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
      score = 0;
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

      if (objectY > 0.85 && (objectX - playerX).abs() < 0.2) {
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
          score += 5;
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

  void movePlayerLeftRight(double direction) {
    setState(() {
      playerX += direction;
      if (playerX > 1) playerX = 1;
      if (playerX < -1) playerX = -1;

      playerDirection = direction < 0 ? 'left' : 'right';
      playerState = 'walk';
    });
  }

  void movePlayerUpDown(double direction) {
    setState(() {
      playerY += direction;
      if (playerY > 1) playerY = 1;
      if (playerY < -1) playerY = -1;

      playerDirection = direction < 0 ? 'back' : 'front';
      playerState = 'walk';
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
      if (playerState == 'walk') {
        setState(() {
          playerState = 'idle';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dodging Game Sample")
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (event){
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyA) {
              movePlayerLeftRight(-0.1);
            } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
              movePlayerLeftRight(0.1);
            } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
              movePlayerUpDown(-0.1);
            } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
              movePlayerUpDown(0.1);
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
            } else if (event.logicalKey == LogicalKeyboardKey.shift){
              setState(() {
                playerState = 'run';
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
              scheduleIdleReset();
            }
          }
        },
        child: Stack(
        children: [
          Container(color: Colors.blueGrey[900]),

          Align(
            alignment: Alignment(objectX, objectY),
            child: Image.asset(
              'dodge/$objectType.png',
              width: 150,
              height: 150,
            ),
          ),

          Align(
            alignment: Alignment(playerX, playerY),
            child: Image.asset(
              playerState == 'idle' 
              ? 'assets/player/${playerDirection}_idle.gif'
              : playerState == 'walk' 
              ? 'assets/player/${playerDirection}_walk.gif'
              : playerState == 'jump' 
              ? 'assets/player/${playerDirection}_jump.gif'
              : playerState == 'run' 
              ? 'assets/player/${playerDirection}_run.gif' 
              : 'assets/player/player_$playerDirection.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            top: 50,
            left: 20,
            child: Text(
              'Score: $score',
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
                  Text('Score: $score',
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

          if (!gameOver && score == 0)
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
