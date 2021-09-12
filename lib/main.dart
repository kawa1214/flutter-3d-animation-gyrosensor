import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart' as sensors;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _interval = 0.02;
  static const _backgroundScale = 1.2;
  static const _backgroundMoveOffsetScale = 0.6;
  static const _maxAngle = 120;
  static const _maxForegroundMove = Offset(50, 50);
  static const _inititalForegroundOffset = Offset(400, 30);
  static const _inititalBackgroundOffset = Offset(0, 0);

  Offset _foregroundOffset = _inititalForegroundOffset;
  Offset _backgroundOffset = _inititalBackgroundOffset;
  late StreamSubscription<sensors.GyroscopeEvent> _streamGyrpscopeEvent;

  @override
  void initState() {
    _streamGyrpscopeEvent =
        sensors.gyroscopeEvents.listen((_listenGyroscopeEvent));
    super.initState();
  }

  void _listenGyroscopeEvent(sensors.GyroscopeEvent event) {
    final angle = Offset(
      event.x * _interval * 180 / pi,
      event.y * _interval * 180 / pi,
    );

    if (angle.dx >= _maxAngle || angle.dy >= _maxAngle) {
      return;
    }

    final addForegroundOffset = Offset(
      angle.dx / _maxAngle * _maxForegroundMove.dx,
      angle.dy / _maxAngle * _maxForegroundMove.dy,
    );

    final newForegroundOffse = _foregroundOffset + addForegroundOffset;

    if (newForegroundOffse.dx >=
            _inititalForegroundOffset.dx + _maxForegroundMove.dx ||
        newForegroundOffse.dx <=
            _inititalForegroundOffset.dx - _maxForegroundMove.dx ||
        newForegroundOffse.dy >=
            _inititalForegroundOffset.dy + _maxForegroundMove.dy ||
        newForegroundOffse.dy <=
            _inititalForegroundOffset.dy - _maxForegroundMove.dy) {
      return;
    }

    setState(() {
      _foregroundOffset = _foregroundOffset + addForegroundOffset;
      _backgroundOffset =
          _backgroundOffset - addForegroundOffset * _backgroundMoveOffsetScale;
    });
  }

  @override
  void dispose() {
    _streamGyrpscopeEvent.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: _backgroundOffset.dx,
            left: _backgroundOffset.dy,
            child: Transform.scale(
              scale: _backgroundScale,
              child: _buildBackgroundImage(size),
            ),
          ),
          Positioned(
            top: _foregroundOffset.dx - _inititalForegroundOffset.dx,
            left: _foregroundOffset.dy - _inititalForegroundOffset.dy,
            child: Transform.scale(
              scale: 1,
              child: _buildEffect(size),
            ),
          ),
          Positioned(
            top: _foregroundOffset.dx,
            left: _foregroundOffset.dy,
            child: _buildHalloween,
          ),
          Positioned(
            top: 160,
            right: 16,
            child: _buildMiddleText,
          ),
        ],
      ),
    );
  }

  Widget get _buildMiddleText => Text(
        '3D効果は\nユーザにどのような影響を\n与えるのだろう...',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      );

  Widget _buildBackgroundImage(Size size) => Image.asset(
        'assets/background.png',
        fit: BoxFit.fitWidth,
        height: size.height,
        width: size.width,
      );

  Widget get _buildHalloween => Image.asset(
        'assets/halloween.png',
        height: 150,
        width: 150,
      );

  Widget _buildEffect(Size size) => Image.asset(
        'assets/effect.png',
        height: size.height,
        width: size.width,
        fit: BoxFit.fitHeight,
      );
}
