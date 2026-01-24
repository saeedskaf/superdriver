// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class FormFieldCustom extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? label;
  final String? prefixText;
  final bool isPassword;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;
  final bool enabled;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const FormFieldCustom({
    super.key,
    this.controller,
    this.hintText,
    this.label,
    this.prefixText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  State<FormFieldCustom> createState() => _FormFieldCustomState();
}

class _FormFieldCustomState extends State<FormFieldCustom> {
  bool _obscureText = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          TextCustom(
            text: widget.label!,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorsCustom.textPrimary,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: widget.enabled ? ColorsCustom.textPrimary : Colors.grey,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.enabled ? Colors.white : ColorsCustom.background,
            hintText: widget.hintText,
            hintStyle: GoogleFonts.cairo(
              fontSize: 15,
              color: ColorsCustom.textPrimary.withOpacity(0.5),
            ),
            prefixText: widget.prefixText,
            prefixStyle: GoogleFonts.cairo(
              fontSize: 15,
              color: ColorsCustom.textPrimary.withOpacity(0.7),
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: _buildBorder(ColorsCustom.textPrimary.withOpacity(0.3)),
            enabledBorder: _buildBorder(
              ColorsCustom.textPrimary.withOpacity(0.3),
            ),
            focusedBorder: _buildBorder(ColorsCustom.primary, width: 2),
            errorBorder: _buildBorder(Colors.red.shade600),
            focusedErrorBorder: _buildBorder(Colors.red.shade600, width: 2),
            disabledBorder: _buildBorder(Colors.grey.shade300),
            errorStyle: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.red.shade600,
            ),
            counterStyle: GoogleFonts.cairo(
              fontSize: 12,
              color: ColorsCustom.textPrimary.withOpacity(0.6),
            ),
          ),
          cursorColor: ColorsCustom.primary,
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget? _buildSuffixIcon() {
    // Password visibility toggle
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: ColorsCustom.textPrimary.withOpacity(0.6),
          size: 22,
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    }

    // Custom suffix icon
    return widget.suffixIcon;
  }
}
