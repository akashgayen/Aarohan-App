import 'package:flutter/material.dart';

class RotatingImage extends StatefulWidget {
  final String imagePath;
  final bool reverse;

  RotatingImage({required this.imagePath, this.reverse = false}); // default direction is clockwise

  @override
  _RotatingImageState createState() => _RotatingImageState();
}

class _RotatingImageState extends State<RotatingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Set duration as needed
    )..repeat(reverse: true);
    if (widget.reverse) {
      _controller.value = 1.0; // Set animation to its final frame
      _controller.repeat(reverse: true); // Reverse the animation indefinitely
    }
    // Set reverse to true to make it rotate counterclockwise
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        widget.imagePath,
        width: 300, // Adjust width as needed
        height: 300, // Adjust height as needed
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
