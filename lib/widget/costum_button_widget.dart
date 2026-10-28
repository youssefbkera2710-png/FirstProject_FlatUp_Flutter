import 'package:flutter/material.dart';

class CostumButtonWidget extends StatelessWidget {
  const CostumButtonWidget({
    super.key,
    this.onTap,
    required this.namebutton,
    required this.colorDecoration,
    required this.colorText,
    this.width,
    this.height = 60,
    this.bordertext
  });

  final String namebutton;
  final Color colorDecoration;
  final Color colorText;
  final double? width;
  final double height;
  final VoidCallback? onTap;
  final double? bordertext;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorDecoration,
          borderRadius: BorderRadius.circular(bordertext ?? 34),
        ),
        child: Center(
          child: Text(
            namebutton,
            style: TextStyle(
              color: colorText,
              fontSize: 18,
              fontFamily: 'CarterOne',
            ),
          ),
        ),
      ),
    );
  }
}
