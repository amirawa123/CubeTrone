import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'shapes.dart';
import 'compile.dart';

void main() {
  runApp(const Opening());
}

class Opening extends StatefulWidget {
  const Opening({super.key});

  @override
  OpeningState createState() => OpeningState();
}

class OpeningState extends State<Opening> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late TextEditingController _textEditingController;
  late bool _isLoading;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    _textEditingController = TextEditingController();
    _isLoading = true;
    numberGenerator();
    navigation();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textEditingController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void numberGenerator() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final random = Random();
      final binaryNumbers = List.generate(8, (_) => random.nextInt(2));
      setState(() {
        _textEditingController.text = binaryNumbers.join();
      });
    });
  }

  void navigation() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cubetrone',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFFFFFFF)),
      home: _isLoading
          ? Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: MediaQuery.of(context).size.width * 0.05,
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: MediaQuery.of(context).size.height * 0.23,
                    child: RotationTransition(
                      turns: _controller,
                      child: Image.asset('images/gear.png'),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.1,
                    right: MediaQuery.of(context).size.width * 0.03,
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: TextField(
                      controller: _textEditingController,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 60,
                        color: Color(0xFFFC650C),
                      ),
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      'images/Visual ID.png',
                    ),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0, 1),
                    endPoint: const Offset(0.07, 0.86),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.0685, 0.8615),
                    endPoint: const Offset(0.11, 0.86),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.1085, 0.8615),
                    endPoint: const Offset(0.18, 0.72),
                  ),
                  buildCirclePainter(
                    centerX: 0.19,
                    centerY: 0.7,
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.05, 1),
                    endPoint: const Offset(0.098, 0.9),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.0965, 0.9015),
                    endPoint: const Offset(0.14, 0.9),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.1385, 0.9015),
                    endPoint: const Offset(0.188, 0.8),
                  ),
                  buildCirclePainter(
                    centerX: 0.2,
                    centerY: 0.78,
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0, 0.9),
                    endPoint: const Offset(0.047, 0.81),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.0455, 0.8115),
                    endPoint: const Offset(0.089, 0.81),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.0875, 0.8115),
                    endPoint: const Offset(0.137, 0.71),
                  ),
                  buildCirclePainter(
                    centerX: 0.145,
                    centerY: 0.684,
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.8, 1),
                    endPoint: const Offset(0.9, 0.85),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.905, 0.843),
                    endPoint: const Offset(0.91, 0.835),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.915, 0.828),
                    endPoint: const Offset(0.98, 0.73),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.985, 0.723),
                    endPoint: const Offset(0.99, 0.715),
                  ),
                  buildLinePainter(
                    startPoint: const Offset(0.87, 1),
                    endPoint: const Offset(1, 0.8),
                    color: Colors.black,
                  ),
                ],
              ),
            )
          : const Home(),
    );
  }
}
