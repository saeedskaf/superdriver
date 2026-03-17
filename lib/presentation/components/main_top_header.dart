import 'package:flutter/material.dart';
import 'package:superdriver/presentation/components/custom_text.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class MainTopHeader extends StatelessWidget {
  final String title;
  final String iconAsset;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final EdgeInsetsGeometry? margin;

  const MainTopHeader({
    super.key,
    required this.title,
    required this.iconAsset,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      margin: margin,
      padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 14),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        border: const Border(
          bottom: BorderSide(color: ColorsCustom.border, width: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                iconAsset,
                width: 42,
                height: 42,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      text: title,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorsCustom.textPrimary,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      TextCustom(
                        text: subtitle!,
                        fontSize: 13,
                        color: ColorsCustom.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (bottom != null) ...[const SizedBox(height: 10), bottom!],
        ],
      ),
    );
  }
}
