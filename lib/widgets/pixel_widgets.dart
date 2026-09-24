import 'package:flutter/material.dart';
import 'package:skribbl_io/theme/pixel_theme.dart';

/// Interactive 3D Pixel Button that compresses on tap
class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Widget? icon;
  final double? width;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const PixelButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = PixelTheme.primaryPink,
    this.textColor = Colors.white,
    this.borderColor,
    this.icon,
    this.width,
    this.height = 48,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final shadowOffset = _isPressed ? 1.0 : 4.0;
    final translateY = _isPressed ? 3.0 : 0.0;
    final effectiveBorder = widget.borderColor ?? PixelTheme.borderDark;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(0, translateY, 0),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: isEnabled ? widget.backgroundColor : Colors.grey.shade300,
          border: PixelTheme.pixelBorder(color: effectiveBorder, width: 3),
          boxShadow: [
            BoxShadow(
              color: effectiveBorder,
              offset: Offset(shadowOffset, shadowOffset),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.text,
                  style: PixelTheme.pixel(
                    fontSize: widget.fontSize,
                    color: isEnabled ? widget.textColor : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A retro RPG style dialogue window with optional pixel title bar
class PixelWindow extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? backgroundColor;
  final Color? headerColor;
  final double padding;
  final double? width;
  final double? height;

  const PixelWindow({
    super.key,
    required this.child,
    this.title,
    this.backgroundColor,
    this.headerColor,
    this.padding = 16.0,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? PixelTheme.bgSurface;
    final header = headerColor ?? PixelTheme.babyPink;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bg,
        border: PixelTheme.pixelBorder(width: 3),
        boxShadow: PixelTheme.pixelShadow(offset: 5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: header,
                border: Border(
                  bottom: BorderSide(color: PixelTheme.borderDark, width: 3),
                ),
              ),
              child: Row(
                children: [
                  const Text('★', style: TextStyle(color: PixelTheme.primaryPink, fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title!,
                      style: PixelTheme.pixel(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: PixelTheme.primaryPink,
                      border: Border.all(color: PixelTheme.borderDark, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: PixelTheme.accentYellow,
                      border: Border.all(color: PixelTheme.borderDark, width: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.all(padding),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// A pixel badge / tag for stats, rooms, timers
class PixelBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final double fontSize;

  const PixelBadge({
    super.key,
    required this.label,
    this.backgroundColor = PixelTheme.accentYellow,
    this.textColor,
    this.icon,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final textCol = textColor ?? (PixelTheme.isDark ? PixelTheme.borderDark : PixelTheme.borderDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: PixelTheme.pixelBorder(width: 2),
        boxShadow: PixelTheme.pixelShadow(offset: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: PixelTheme.pixel(
              fontSize: fontSize,
              color: textCol,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A cute pixel toggle button for switching between Light and Dark mode
class PixelThemeToggle extends StatelessWidget {
  final double height;
  final double? width;
  final double fontSize;

  const PixelThemeToggle({
    super.key,
    this.height = 36,
    this.width,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PixelTheme.isDarkMode,
      builder: (context, isDark, _) {
        return PixelButton(
          text: isDark ? '☀️ LIGHT' : '🌙 DARK',
          fontSize: fontSize,
          height: height,
          width: width,
          backgroundColor: isDark ? PixelTheme.accentYellow : PixelTheme.primaryPink,
          textColor: isDark ? PixelTheme.shadowDark : Colors.white,
          onPressed: () => PixelTheme.toggleDarkMode(),
        );
      },
    );
  }
}
