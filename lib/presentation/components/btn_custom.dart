// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? color;
  final Color? textColor;
  final double height;
  final double? width;
  final Widget? icon;
  final bool isOutlined;

  const ButtonCustom({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.color,
    this.textColor,
    this.height = 50,
    this.width,
    this.icon,
    this.isOutlined = false,
  });

  // Primary button (filled with primary color)
  const ButtonCustom.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.height = 50,
    this.width,
    this.icon,
  }) : color = ColorsCustom.primary,
       textColor = Colors.white,
       isOutlined = false;

  // Secondary button (outlined style)
  const ButtonCustom.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.height = 50,
    this.width,
    this.icon,
  }) : color = null,
       textColor = ColorsCustom.primary,
       isOutlined = true;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !enabled || onPressed == null || isLoading;

    final Color buttonColor = isOutlined
        ? Colors.transparent
        : (color ?? ColorsCustom.primary);

    final Color buttonTextColor = isOutlined
        ? (textColor ?? ColorsCustom.primary)
        : (textColor ?? Colors.white);

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          elevation: isOutlined ? 0 : 2,
          shadowColor: ColorsCustom.primary.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutlined
                ? BorderSide(
                    color: isDisabled
                        ? Colors.grey.shade300
                        : (color ?? ColorsCustom.primary),
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          disabledBackgroundColor: isOutlined
              ? Colors.transparent
              : Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDisabled ? Colors.grey.shade500 : buttonTextColor,
                  ),
                ),
              )
            : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  Flexible(
                    child: TextCustom(
                      text: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? Colors.grey.shade500
                          : buttonTextColor,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              )
            : TextCustom(
                text: text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDisabled ? Colors.grey.shade500 : buttonTextColor,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
      ),
    );
  }
}
