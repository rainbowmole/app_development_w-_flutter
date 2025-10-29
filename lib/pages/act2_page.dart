import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

<<<<<<< HEAD
class ActivityPage2 extends StatelessWidget {
  const ActivityPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dodge Game Sample',
      theme: ThemeData.dark(),
      home: const AvoidGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AvoidGame extends StatefulWidget {
  const AvoidGame({super.key});

  @override
  State<AvoidGame> createState() => _AvoidGameState();
}


class _AvoidGameState extends State<AvoidGame> {
  double playerX = 0;
  double objectX = Random().nextDouble() * 2 - 1;
  double objectY = -1;
=======
class ActivityPage2 extends StatefulWidget {
  const ActivityPage2({super.key});

  @override
  _AvoidGameState createState() => _AvoidGameState();
}

class _AvoidGameState extends State<ActivityPage2> {
  double playerX = 0;
  double playerY = -1;

  double objectX = Random().nextDouble() * 2 - 1;
  double objectY = -1;

>>>>>>> 10cd1941ce39992afe3822c94f885ac4e5752bff
  int score = 0;
  bool gameOver = false;
  late Timer gameTimer;
  String objectType = 'avoid';

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
      score = 0;
      gameOver = false;
      objectY = -1;
      objectX = Random().nextDouble() * 2 - 1;
      objectType = Random().nextBool() ? 'avoid' : 'collect';
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
          gameOver = true;
          gameTimer.cancel();
          return;
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

<<<<<<< HEAD
  void movePlayer(double direction) {
=======
  void movePlayerLeftRight(double direction) {
>>>>>>> 10cd1941ce39992afe3822c94f885ac4e5752bff
    setState(() {
      playerX += direction;
      if (playerX > 1) playerX = 1;
      if (playerX < -1) playerX = -1;
    });
  }

<<<<<<< HEAD
=======
  void movePlayerUpDown(double direction) {
    setState(() {
      playerY += direction;
      if (playerY > 1) playerX = 1;
      if (playerY < -1) playerX = -1;
    });
  }

>>>>>>> 10cd1941ce39992afe3822c94f885ac4e5752bff
  @override
  void dispose() {
    if (gameTimer.isActive) gameTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
=======
      appBar: AppBar(
        title: const Text("Dodging Game Sample")
      ),
>>>>>>> 10cd1941ce39992afe3822c94f885ac4e5752bff
      body: RawKeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKey: (event){
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyA) {
<<<<<<< HEAD
              movePlayer(-0.1);
            } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
              movePlayer(0.1);
=======
              movePlayerLeftRight(-0.1);
            } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
              movePlayerLeftRight(0.1);
            } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
              movePlayerUpDown(-0.1);
            } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
              movePlayerUpDown(0.1);
            } else if (event.logicalKey == LogicalKeyboardKey.enter){
              startGame();
>>>>>>> 10cd1941ce39992afe3822c94f885ac4e5752bff
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
            alignment: Alignment(playerX, 0.9),
            child: Image.asset(
<<<<<<< HEAD
              'dodge/player.png',
              width: 250,
              height: 250,
=======
              'assets/player/player.png',
              width: 120,
              height: 120,
>>>>>>> 10cd1941ce39992afe3822c94f885ac4e5752bff
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
<<<<<<< HEAD
                child: const Text('Start Game'),
=======
                child: const Text('Press ENTER to Start Game'),
>>>>>>> 10cd1941ce39992afe3822c94f885ac4e5752bff
              ),
            ),
        ],
      ),
      ),

      bottomNavigationBar: Container(
        color: Colors.black87,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
<<<<<<< HEAD
            IconButton(
              onPressed: () => movePlayer(-0.1),
              icon: const Icon(Icons.arrow_left, size: 40),
            ),
            IconButton(
              onPressed: () => movePlayer(0.1),
              icon: const Icon(Icons.arrow_right, size: 40),
            ),
=======
            const Text('PRESS A TO MOVE LEFT, PRESS D TO MOVE RIGHT')
>>>>>>> 10cd1941ce39992afe3822c94f885ac4e5752bff
          ],
        ),
      ),
    );
  }
}
