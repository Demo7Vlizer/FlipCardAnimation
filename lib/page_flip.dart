import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart'; // Add this import to access LightHomePage and DarkHomePage

class PageFlip extends StatefulWidget {
  const PageFlip({Key? key}) : super(key: key);

  @override
  State<PageFlip> createState() => _PageFlipState();
}

class _PageFlipState extends State<PageFlip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showFrontSide = true;
  
  // Add drag threshold
  final double _flipThreshold = 0.3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    setState(() => _showFrontSide = !_showFrontSide);
    if (_showFrontSide) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  // Add drag handling methods
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragPercentage = (details.primaryDelta ?? 0) / screenWidth;
    
    if (_showFrontSide) {
      _controller.value += dragPercentage;
    } else {
      _controller.value -= dragPercentage;
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_controller.value >= _flipThreshold) {
      _controller.forward().then((_) {
        setState(() => _showFrontSide = false);
      });
    } else if (_controller.value <= (1 - _flipThreshold)) {
      _controller.reverse().then((_) {
        setState(() => _showFrontSide = true);
      });
    } else if (_showFrontSide) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _showFrontSide
                ? LightHomePage(onFlip: _flip)
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: DarkHomePage(onFlip: _flip),
                  ),
          );
        },
      ),
    );
  }
}
