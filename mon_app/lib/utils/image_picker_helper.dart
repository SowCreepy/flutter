import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

Future<({Uint8List bytes, String name})?> pickImageFromGallery() async {
  try {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (xFile == null) {
      debugPrint('[ImagePicker] User cancelled');
      return null;
    }
    final bytes = await xFile.readAsBytes();
    debugPrint(
      '[ImagePicker] Picked ${xFile.name}, ${bytes.length} bytes, mime=${xFile.mimeType}',
    );
    return (bytes: bytes, name: xFile.name);
  } catch (e, st) {
    debugPrint('[ImagePicker] Error: $e\n$st');
    return null;
  }
}
