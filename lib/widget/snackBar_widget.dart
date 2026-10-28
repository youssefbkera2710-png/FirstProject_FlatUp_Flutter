import 'dart:ui';
import 'package:flutter/material.dart';

enum SnackType { success, error, warning, waitting }

void SnackBarWidget(BuildContext context, String message, SnackType type) {
  Color bgColor;
  IconData icon;
  switch (type) {
    case SnackType.waitting:
      bgColor = Colors.lightBlue.withOpacity(0.6);
      icon = Icons.timeline_rounded;
      break;
    case SnackType.success:
      bgColor = Colors.green.withOpacity(0.6);
      icon = Icons.check_circle_rounded;
      break;

    case SnackType.error:
      bgColor = Colors.red.withOpacity(0.6);
      icon = Icons.error_rounded;
      break;

    case SnackType.warning:
      bgColor = Colors.amber.withOpacity(0.6);
      icon = Icons.warning_rounded;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
