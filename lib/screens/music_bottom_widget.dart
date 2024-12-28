import 'package:flutter/material.dart';

class SlidingBottomSheet extends StatefulWidget {
  const SlidingBottomSheet({super.key});

  @override
  State<SlidingBottomSheet> createState() => _SlidingBottomSheetState();
}

class _SlidingBottomSheetState extends State<SlidingBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeSheet() {
    _controller.reverse().then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset:
              Offset(0, MediaQuery.of(context).size.height * _animation.value),
          child: Container(
            height: 200, // Adjust height as needed
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black..withAlpha(26),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeSheet,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
