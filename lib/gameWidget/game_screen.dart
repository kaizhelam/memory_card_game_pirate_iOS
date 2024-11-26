import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late Timer _timer;
  int remainingTime = 60;
  int moves = 0;
  late AnimationController _controller;
  bool showCongratsMessage = false;
  late Animation<double> _opacityAnimation;
  int currentLevel = 1;

  final List<String> matchMessage = [
    "Nailed it! 🎯",
    "Boom! 💥",
    "You’re unstoppable! 🚀",
    "Match master! 🏆",
    "Two peas in a pod! 🌱",
    "You're a match wizard! 🧙‍♂️",
    "Perfectly paired! 🎉",
    "Superb! 🌟",
    "Card genius! 🧠",
  ];

  List<String> images = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
    'assets/images/4.png',
    'assets/images/5.png',
    'assets/images/6.png',
  ];
  late List<String> gameGrid;
  late List<bool> cardFlipped;
  String questionMark = 'assets/images/question_mark.png';
  int? firstFlippedIndex;
  int? secondFlippedIndex;
  bool allowClick = true;
  String message = "";
  bool checkCards = true;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _startTimer();
    _initializeGame();
  }

  void _initializeGame() {
    int cardCount;
    switch (currentLevel) {
      case 1:
        cardCount = 6;
        checkCards = true;
        break;
      case 2:
        cardCount = 12;
        checkCards = false;
        break;
      default:
        cardCount = 6;
        currentLevel = 1;
        checkCards = true;
    }

    final shuffledImages = [
      ...images.sublist(0, cardCount ~/ 2),
      ...images.sublist(0, cardCount ~/ 2)
    ]..shuffle(Random());
    gameGrid = shuffledImages;
    cardFlipped = List<bool>.filled(gameGrid.length, false);
    firstFlippedIndex = null;
    secondFlippedIndex = null;
    allowClick = true;
    moves = 0;
    remainingTime = 60;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          _timer.cancel();
          if (currentLevel == 1) {
            _gameEndDialog(
                "Time's Up!", "You ran out of time! Want to restart?",
                restartOnly: true);
          } else if (currentLevel == 2) {
            _gameEndDialog(
                "Time's Up!", "You ran out of time! Want to restart?",
                restartOnly: true);
          }
        }
      });
    });
  }

  void _showMessageAnimation() {
    setState(() {
      showCongratsMessage = true;
    });
    _controller.forward();

    message = matchMessage[Random().nextInt(matchMessage.length)];

    Future.delayed(const Duration(seconds: 2), () {
      _controller.reverse();
      setState(() {
        showCongratsMessage = false;
      });
    });
  }

  void _onWin() async {
    _confettiController.play();
    _timer.cancel();
    await Future.delayed(const Duration(seconds: 5));
    if (currentLevel == 1) {
      _gameEndDialog(
        "Congratulations!",
        "You won the game with $moves moves! Proceed to the next level?",
        nextLevel: true,
      );
    } else if (currentLevel == 2) {
      _gameEndDialog(
        "Congratulations!",
        "You won the game with $moves moves! Want to restart?",
        restartOnly: true,
      );
    }
  }

  void _gameEndDialog(String title, String message,
      {bool nextLevel = false, bool restartOnly = false}) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.spicyRice(fontSize: 38),
        ),
        content: Text(
          message,
          style: GoogleFonts.spicyRice(fontSize: 20),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Quit",
              style: GoogleFonts.spicyRice(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (currentLevel == 1 && !restartOnly)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  currentLevel++;
                });
                _initializeGame();
                _startTimer();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0D47A1),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Next Level",
                style: GoogleFonts.spicyRice(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (restartOnly)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  currentLevel = 1;
                });
                _initializeGame();
                _startTimer();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0D47A1),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Restart",
                style: GoogleFonts.spicyRice(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onCardTapped(int index) async {
    if (!allowClick || cardFlipped[index]) return;

    setState(() {
      cardFlipped[index] = true;
    });

    if (firstFlippedIndex == null) {
      firstFlippedIndex = index;
    } else if (secondFlippedIndex == null) {
      secondFlippedIndex = index;

      setState(() {
        moves++;
      });

      if (gameGrid[firstFlippedIndex!] == gameGrid[secondFlippedIndex!]) {
        firstFlippedIndex = null;
        secondFlippedIndex = null;
        _showMessageAnimation();
        if (cardFlipped.every((isFlipped) => isFlipped)) {
          _onWin();
        }
      } else {
        allowClick = false;
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          cardFlipped[firstFlippedIndex!] = false;
          cardFlipped[secondFlippedIndex!] = false;
          firstFlippedIndex = null;
          secondFlippedIndex = null;
        });
        allowClick = true;
      }
    }
  }

  Widget buildCard(String imagePath, bool isFlipped) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final flipAnimation = Tween(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: flipAnimation,
          builder: (context, child) {
            final angle = flipAnimation.value;
            final isFront = angle < pi / 2;

            return Transform(
              transform: Matrix4.rotationY(angle),
              alignment: Alignment.center,
              child: isFront ? child : Container(color: Colors.transparent),
            );
          },
          child: child,
        );
      },
      child: isFlipped
          ? Image.asset(
              imagePath,
              fit: BoxFit.cover,
              key: ValueKey(imagePath),
            )
          : Container(
              key: const ValueKey('question'),
              child: Image.asset(
                questionMark,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C),
              Color(0xFF311B92),
              Color(0xFF1A237E),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow
                ],
              ),
            ),
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80, right: 30, left: 30),
                  child: Column(
                    children: [
                      Text("Memory Card Game",
                          style: GoogleFonts.spicyRice(
                            fontSize: 42,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 5),
                      Text(
                        "Match the cards to win!",
                        style: GoogleFonts.spicyRice(
                          fontSize: 26,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Level $currentLevel",
                        style: GoogleFonts.spicyRice(
                          fontSize: 26,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 240, right: 24, left: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Moves: $moves",
                    style: GoogleFonts.spicyRice(
                        color: Colors.white, fontSize: 33),
                  ),
                  Text(
                    "Time: $remainingTime s",
                    style: GoogleFonts.spicyRice(
                        color: Colors.white, fontSize: 33),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: checkCards ? 300 : 245, right: 16, left: 16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8),
                itemCount: gameGrid.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCardTapped(index),
                    child: buildCard(
                      gameGrid[index],
                      cardFlipped[index],
                    ),
                  );
                },
              ),
            ),
            if (showCongratsMessage)
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 35),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: const Offset(0, 0),
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOut,
                      )),
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: Text(
                          message,
                          style: GoogleFonts.spicyRice(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _timer.cancel();
    super.dispose();
  }
}