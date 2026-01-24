import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class TextCustom extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextOverflow overflow;
  final int? maxLines;
  final TextAlign textAlign;
  final double? height;
  final TextDecoration? decoration;
  final double? letterSpacing;

  const TextCustom({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = ColorsCustom.textPrimary,
    this.fontWeight = FontWeight.normal,
    this.overflow = TextOverflow.visible,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.height,
    this.decoration,
    this.letterSpacing,
  });

  const TextCustom.heading({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.color = ColorsCustom.textPrimary,
    this.fontWeight = FontWeight.bold,
    this.overflow = TextOverflow.visible,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.height,
    this.decoration,
    this.letterSpacing,
  });

  const TextCustom.subheading({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.color = ColorsCustom.textPrimary,
    this.fontWeight = FontWeight.w600,
    this.overflow = TextOverflow.visible,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.height,
    this.decoration,
    this.letterSpacing,
  });

  const TextCustom.body({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.color = ColorsCustom.textPrimary,
    this.fontWeight = FontWeight.normal,
    this.overflow = TextOverflow.visible,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.height = 1.5,
    this.decoration,
    this.letterSpacing,
  });

  const TextCustom.caption({
    super.key,
    required this.text,
    this.fontSize = 12,
    this.color = ColorsCustom.textPrimary,
    this.fontWeight = FontWeight.w400,
    this.overflow = TextOverflow.visible,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.height,
    this.decoration,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final hasArabic = text.contains(RegExp(r'[\u0600-\u06FF]'));

    return Text(
      text,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      textDirection: hasArabic ? TextDirection.rtl : TextDirection.ltr,
      style: hasArabic
          ? GoogleFonts.cairo(
              fontSize: fontSize,
              color: color,
              fontWeight: fontWeight,
              height: height,
              decoration: decoration,
              letterSpacing: letterSpacing,
            )
          : GoogleFonts.outfit(
              fontSize: fontSize,
              color: color,
              fontWeight: fontWeight,
              height: height,
              decoration: decoration,
              letterSpacing: letterSpacing ?? 0.5,
            ),
    );
  }
}
