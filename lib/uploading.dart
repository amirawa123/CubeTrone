import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';

class Uploading extends StatefulWidget {
  const Uploading({super.key});

  @override
  UploadingState createState() => UploadingState();
}

class UploadingState extends State<Uploading> {
  int _currentIndex = 0;
  final List<String> _images = ['images/Logo1.png', 'images/Logo2.png'];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(milliseconds: 250),
        builder: (context) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Image.asset(
          _images[_currentIndex],
          key: ValueKey(_currentIndex),
        ),
      );
    });
  }
}
