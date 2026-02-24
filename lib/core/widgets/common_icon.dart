import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Format-agnostic asset widget.
/// Renders SVG via [SvgPicture.asset] and PNG/other via [Image.asset].
/// Use for all Figma-exported icons and images to stay format-agnostic.
class CommonIcon extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final double? size;
  final Color? color;
  final BoxFit fit;

  const CommonIcon({
    required this.path,
    this.width,
    this.height,
    this.size,
    this.color,
    this.fit = BoxFit.contain,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final w = size ?? width;
    final h = size ?? height;

    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: w,
        height: h,
        fit: fit,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
      );
    }

    return Image.asset(path, width: w, height: h, fit: fit, color: color);
  }
}
