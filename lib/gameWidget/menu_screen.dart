import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    const Offset(0.4, 0.1),
    const Offset(0.65, 0.2),
    const Offset(0.05, 0.23),
    const Offset(0.41, 0.66),
    const Offset(0.04, 0.76),
    const Offset(0.65, 0.75),
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

  Widget textTitle() {
    return Text(
      "Treasure Map Memory",
      textAlign: TextAlign.center,
      style: GoogleFonts.spicyRice(
          color: Colors.white, fontSize: 38.sp, fontWeight: FontWeight.bold),
    );
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
      child: Center(
        child: Image.asset(
          "assets/images/button-start.png",
          width: 200.h,
        ),
      ),
    );
  }

  List<Offset> _calculatePositions() {
    return _positions.map((relativeOffset) {
      return Offset(
        1.sw * relativeOffset.dx,
        1.sh * relativeOffset.dy,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dynamicPositions = _calculatePositions();

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
                top: dynamicPositions[index].dy,
                left: dynamicPositions[index].dx,
                child: AnimatedOpacity(
                  duration: const Duration(seconds: 1),
                  opacity: _visibilityStates[index] ? 1.0 : 0.0,
                  child: SizedBox(
                    width: 100.h,
                    height: 100.h,
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }),

            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  textTitle(),
                  SizedBox(height: 30.h),
                  playButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
