import 'package:flutter/material.dart';
import '../utils/screen_utils.dart';

/// Widget teks yang adaptif dan mengatur ulang ukuran untuk mencegah overflow
class FlexibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool useFittedBox;

  const FlexibleText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.useFittedBox = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan ScreenUtils diinisialisasi
    ScreenUtils.init(context);

    // Ukuran font yang aman (adaptif dan dibatasi)
    final safeTextSize = style?.fontSize == null
        ? 14.0
        : style!.fontSize!.clamp(8.0, ScreenUtils.maxFontSize);

    final TextStyle defaultStyle = TextStyle(
      fontFamily: 'Courier',
      fontSize: safeTextSize,
      color: Colors.white,
    );

    final TextStyle effectiveStyle =
        style?.copyWith(fontSize: safeTextSize) ?? defaultStyle;

    // Gunakan FittedBox untuk mengatur skala secara otomatis jika diminta
    if (useFittedBox) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: effectiveStyle,
          textAlign: textAlign,
          maxLines: maxLines ?? 1,
          overflow: overflow,
        ),
      );
    }

    // Tampilan text standar yang aman
    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines ?? 1,
      overflow: overflow,
    );
  }
}
