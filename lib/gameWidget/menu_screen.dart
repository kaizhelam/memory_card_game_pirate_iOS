import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memory_card_game/gameWidget/game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<String> images = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
    'assets/images/4.png',
    'assets/images/5.png',
    'assets/images/6.png',
  ];

  final List<Offset> _positions = [
    Offset(140, 60),
    Offset(270, 140),
    Offset(20, 216), 
    Offset(175, 620), 
    Offset(15, 690),
    Offset(270, 760), 
  ];

  final List<bool> _visibilityStates = List<bool>.filled(6, false);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        for (int i = 0; i < _visibilityStates.length; i++) {
          _visibilityStates[i] = !_visibilityStates[i];
        }
      });
    });
  }

  Widget textTitle(){
    return  Positioned(top: 420, right:0, left:0, child: Center(child: Text("Treasure Map Memory", style: GoogleFonts.spicyRice(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),));
  }

  Widget playButton() {
    return GestureDetector(
      onTap: () {
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MemoryGame(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 160),
        child: Center(
          child: Image.asset(
            "assets/images/button-start.png",
            width: 250,
          ),
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
          // Image Stack
          ...List.generate(images.length, (index) {
            return Positioned(
              top: _positions[index].dy,
              left: _positions[index].dx,
              child: AnimatedOpacity(
                duration: const Duration(seconds: 1),
                opacity: _visibilityStates[index] ? 1.0 : 0.0,
                child: Image.asset(
                  images[index],
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
          textTitle(),
          playButton()
        ],
      ),
    ));
  }
}
