import 'dart:convert' show base64Decode, base64Encode;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';

/// Maximum image size in bytes (350 KB).
const int _kMaxImageBytes = 350 * 1024;

/// Lets the user pick an image file and returns its base-64 encoded string.
///
/// Returns `null` when the user cancels, the file is empty, or it exceeds the
/// 350 KB limit. A [SnackBar] is shown on errors.
Future<String?> pickImageAsBase64(BuildContext context) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    final bytes = result.files.single.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image invalide. Choisissez un autre fichier.'),
          ),
        );
      }
      return null;
    }
    if (bytes.length > _kMaxImageBytes) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Image trop lourde (> 350 KB). Reduisez la taille pour garantir la sauvegarde locale.',
            ),
          ),
        );
      }
      return null;
    }
    return base64Encode(bytes);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible de charger l'image."),
        ),
      );
    }
    return null;
  }
}

/// Renders a decoded base-64 image or a placeholder icon.
///
/// If [imageBase64] is non-empty and decodable, an [Image.memory] is returned
/// inside a rounded clip. Otherwise a muted icon placeholder is shown.
Widget buildAnimalPhoto({
  required String imageBase64,
  double size = 52,
  IconData fallbackIcon = LucideIcons.image,
  double borderRadius = 12,
}) {
  if (imageBase64.trim().isNotEmpty) {
    try {
      final Uint8List bytes = base64Decode(imageBase64);
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      // Corrupt data -- fall through to the error placeholder.
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Icon(
          LucideIcons.alertTriangle,
          color: Color(0xFFB91C1C),
          size: 18,
        ),
      );
    }
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: Icon(
      fallbackIcon,
      color: AppColors.textMuted.withAlpha(120),
      size: size * 0.4,
    ),
  );
}
