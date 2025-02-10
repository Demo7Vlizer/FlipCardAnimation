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
  final double _flipThreshold = 0.3;
  double _dragStartX = 0;

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

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentX = details.globalPosition.dx;
    final dragDistance = currentX - _dragStartX;
    final dragPercentage = (dragDistance / screenWidth).clamp(-1.0, 1.0);
    
    if (_showFrontSide) {
      _controller.value = dragPercentage.abs();
    } else {
      _controller.value = 1 - dragPercentage.abs();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    
    if (velocity.abs() > 300) {
      if (velocity < 0) {
        _completeFlip();
      } else {
        _resetFlip();
      }
      return;
    }

    if (_controller.value > _flipThreshold) {
      _completeFlip();
    } else {
      _resetFlip();
    }
  }

  void _completeFlip() {
    if (_showFrontSide) {
      _controller.forward().then((_) {
        setState(() => _showFrontSide = false);
      });
    } else {
      setState(() => _showFrontSide = true);
      _controller.reverse();
    }
  }

  void _resetFlip() {
    if (_showFrontSide) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final isBackSide = angle >= (pi / 2);

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isBackSide
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: DarkHomePage(onFlip: _flip),
                  )
                : LightHomePage(onFlip: _flip),
          );
        },
      ),
    );
  }
}
