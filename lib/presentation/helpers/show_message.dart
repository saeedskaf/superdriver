import 'package:flutter/material.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ShowMessage {
  // Show custom message
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: TextCustom(
                text: message,
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? ColorsCustom.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Success message
  static void success(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: ColorsCustom.primary,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  // Error message
  static void error(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline_rounded,
    );
  }

  // Info message
  static void info(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info_outline_rounded,
    );
  }
}
