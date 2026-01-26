import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// Encodes image files into Base64 while enforcing size limits and logging status for debugging.
class ImageEncoderService {
  static const int _defaultMaxFileSizeBytes = 5 * 1024 * 1024;

  const ImageEncoderService({int? maxFileSizeBytes})
      : _maxFileSizeBytes = maxFileSizeBytes ?? _defaultMaxFileSizeBytes;

  final int _maxFileSizeBytes;

  /// Encodes the [file] into a Base64 string after validating its size.
  Future<String> encodeFile(File file, {int? maxBytes}) async {
    return encodeFilePath(file.path, maxBytes: maxBytes);
  }

  /// Encodes a file located at [path].
  Future<String> encodeFilePath(String path, {int? maxBytes}) async {
    final file = File(path);
    if (!await file.exists()) {
      throw ImageEncodingException('Image file not found at $path');
    }

    final limit = maxBytes ?? _maxFileSizeBytes;
    final fileSize = await file.length();
    if (fileSize > limit) {
      throw ImageEncodingException(
        'Image at $path exceeds the maximum allowed size of $limit bytes (actual $fileSize bytes).',
      );
    }

    final bytes = await file.readAsBytes();
    return _encodeBytes(bytes, path, limit);
  }

  /// Encodes raw [bytes] if they are under the allowed [maxBytes].
  Future<String> encodeBytes(Uint8List bytes, {int? maxBytes}) async {
    final limit = maxBytes ?? _maxFileSizeBytes;
    if (bytes.length > limit) {
      throw ImageEncodingException(
        'Image byte data exceeds the maximum allowed size of $limit bytes (actual ${bytes.length} bytes).',
      );
    }
    return _encodeBytes(bytes, null, limit);
  }

  String _encodeBytes(Uint8List bytes, String? path, int limit) {
    final encoded = base64Encode(bytes);
    if (kDebugMode) {
      final location = path != null ? ' ($path)' : '';
      debugPrint(
        'ImageEncoderService: encoded$location, raw ${bytes.length} bytes, base64 ${encoded.length} chars, limit $limit bytes',
      );
    }
    return encoded;
  }

  /// Removes data URI headers like `data:image/png;base64,` if present.
  static String stripDataUriPrefix(String value) {
    const base64Marker = 'base64,';
    final markerIndex = value.indexOf(base64Marker);
    if (markerIndex == -1) return value;
    return value.substring(markerIndex + base64Marker.length);
  }
}

class ImageEncodingException implements Exception {
  ImageEncodingException(this.message, [this.inner]);

  final String message;
  final Object? inner;

  @override
  String toString() => 'ImageEncodingException: $message${inner != null ? ' ($inner)' : ''}';
}
