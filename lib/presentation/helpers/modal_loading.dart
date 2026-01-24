import 'package:flutter/material.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class LoadingModal {
  static bool _isShowing = false;

  // Show loading modal
  static void show(BuildContext context, {String? message}) {
    if (_isShowing) return; // Prevent multiple modals

    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      useRootNavigator: true,
      builder: (context) => PopScope(
        canPop: false, // Prevent back button dismiss
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: ColorsCustom.primary,
                  strokeWidth: 3,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  TextCustom(
                    text: message,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ColorsCustom.textPrimary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).then((_) => _isShowing = false);
  }

  // Dismiss loading modal
  static void dismiss(BuildContext context) {
    if (_isShowing) {
      Navigator.of(context, rootNavigator: true).pop();
      _isShowing = false;
    }
  }

  // Check if modal is currently showing
  static bool get isShowing => _isShowing;
}
