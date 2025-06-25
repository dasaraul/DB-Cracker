import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Container dengan styling ctOS yang elegan dan responsif
class CtOSContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool showBorder;
  final bool showGlow;
  final Color? backgroundColor;
  final Color? borderColor;

  const CtOSContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.showBorder = true,
    this.showGlow = false,
    this.backgroundColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(8.0),
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? CtOSColors.surface,
        border: showBorder
            ? Border.all(
                color: borderColor ?? CtOSColors.border,
                width: 1.0,
              )
            : null,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: CtOSColors.glow.withOpacity(0.3),
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
              ]
            : [
                BoxShadow(
                  color: CtOSColors.shadow,
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}

/// Text widget dengan styling ctOS
class CtOSText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool isMonospace;

  const CtOSText(
    this.text, {
    Key? key,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.isMonospace = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        color: color ?? CtOSColors.textPrimary,
        fontSize: fontSize ?? 14.0,
        fontWeight: fontWeight ?? FontWeight.normal,
        fontFamily: isMonospace ? 'Courier' : null,
        letterSpacing: isMonospace ? 0.5 : null,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Header dengan styling ctOS
class CtOSHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showDivider;

  const CtOSHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CtOSText(
                    title,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: CtOSColors.primary,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4.0),
                    CtOSText(
                      subtitle!,
                      fontSize: 12.0,
                      color: CtOSColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 12.0),
          Container(
            height: 1.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CtOSColors.primary.withOpacity(0.0),
                  CtOSColors.primary,
                  CtOSColors.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0),
        ],
      ],
    );
  }
}

/// Button dengan styling ctOS
class CtOSButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;
  final double? width;

  const CtOSButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 48.0,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? CtOSColors.primary : CtOSColors.surface,
          foregroundColor: isPrimary ? CtOSColors.background : CtOSColors.textPrimary,
          side: BorderSide(
            color: isPrimary ? CtOSColors.primary : CtOSColors.border,
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? CtOSColors.background : CtOSColors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18.0),
                    const SizedBox(width: 8.0),
                  ],
                  CtOSText(
                    text,
                    color: isPrimary ? CtOSColors.background : CtOSColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Status indicator dengan styling ctOS
class CtOSStatusIndicator extends StatefulWidget {
  final bool isActive;
  final String label;
  final double size;

  const CtOSStatusIndicator({
    Key? key,
    required this.isActive,
    required this.label,
    this.size = 12.0,
  }) : super(key: key);

  @override
  _CtOSStatusIndicatorState createState() => _CtOSStatusIndicatorState();
}

class _CtOSStatusIndicatorState extends State<CtOSStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CtOSStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isActive
                    ? CtOSColors.primary.withOpacity(0.3 + 0.7 * _animationController.value)
                    : CtOSColors.textTertiary,
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: CtOSColors.primary.withOpacity(0.5),
                          blurRadius: 4.0,
                          spreadRadius: 1.0,
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        const SizedBox(width: 8.0),
        CtOSText(
          widget.label,
          fontSize: 12.0,
          color: widget.isActive ? CtOSColors.textPrimary : CtOSColors.textSecondary,
        ),
      ],
    );
  }
}
