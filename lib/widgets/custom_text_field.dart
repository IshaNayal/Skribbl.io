import 'package:flutter/material.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onSubmitted,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PixelTheme.inputFill,
        border: PixelTheme.pixelBorder(width: 3),
        boxShadow: PixelTheme.pixelShadow(offset: 3),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        textCapitalization: textCapitalization,
        textAlign: textAlign,
        style: style ?? PixelTheme.pixel(fontSize: 14, color: PixelTheme.borderDark),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: PixelTheme.pixel(
            fontSize: 12,
            color: PixelTheme.borderDark.withValues(alpha: 0.4),
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
