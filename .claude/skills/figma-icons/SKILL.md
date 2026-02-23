---
name: figma-icons
description: Export and integrate SVG icons from Figma into AeroSense. Use when adding new icons or updating existing ones from technical designs.
---

# Figma Icons Skill

Workflow for accurately fetching and integrating icons from Figma into the AeroSense Flutter project.

## Workflow

### 1. Identify Icon in Figma
Use the Figma MCP to find the specific icon or frame.
```bash
# List frames in a page (replace with actual file/page info)
# figma.get_file_nodes(file_key="...", ids=["..."])
```

### 2. Export Format
Choose the format based on the icon's complexity:
- **SVG**: Preferred for simple icons and illustrations (scalable, smaller size).
- **PNG**: Use for complex illustrations or when SVG rendering issues occur.

### 3. File Naming & Location
- **Directory Setup**: Check if `assets/` exists; if not, create it. Do the same for `assets/icons/` and `assets/images/`.
- **Location**: `assets/icons/` or `assets/images/`
- **Naming**: `snake_case` (e.g., `ic_weather_sunny.svg`, `img_cloud_pattern.png`)
- **Folder Registration**: Ensure paths are in `pubspec.yaml`.

### 4. Code Integration (Dynamic Loading)
Use a common pattern to handle different file types automatically.

**CommonIcon Widget Example**:
```dart
class CommonIcon extends StatelessWidget {
  final String path;
  final double? size;
  final Color? color;

  const CommonIcon({required this.path, this.size, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      );
    } else {
      return Image.asset(
        path,
        width: size,
        height: size,
        color: color,
      );
    }
  }
}
```

## Conversion Support

If you need to convert between formats (e.g., SVG to PNG for a specific use case):

### CLI Conversion (FFmpeg)
If `ffmpeg` is installed on your system:
```bash
# Convert SVG to PNG (requires a high-quality rasterizer like inkscape or using ffmpeg with librsvg)
ffmpeg -i input.svg output.png
```

### In-App Conversion (FFmpeg Kit)
Add `ffmpeg_kit_flutter_new` to `pubspec.yaml`:
```yaml
dependencies:
  ffmpeg_kit_flutter_new: ^4.1.0
```

Example usage for conversion or processing:
```dart
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';

void convertImage(String inputPath, String outputPath) async {
  await FFmpegKit.execute('-i $inputPath $outputPath').then((session) async {
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      // Success
    } else {
      // Error
    }
  });
}
```

## Guidelines
- **Always prefix** icons with `ic_` and images with `img_`.
- Use `CommonIcon` (or similar pattern) to remain format-agnostic in the UI layer.
- Prefer SVGs for icons to ensure sharpness across all screen densities.
