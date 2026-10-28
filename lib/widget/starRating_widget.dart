import 'package:flat_up/widget/starPainter_widget.dart';
import 'package:flutter/material.dart';

class StarratingWidget extends StatelessWidget {
  final double rating; // من 0 إلى 5
  final int starCount;
  final double size;
  final Color color;

  const StarratingWidget({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 28,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final starValue = rating - index;
        return CustomPaint(
          size: Size(size, size),
          painter: StarpainterWidget(
            fillPercent: starValue.clamp(0.0, 1.0),
            color: color,
          ),
        );
      }),
    );
  }
}
