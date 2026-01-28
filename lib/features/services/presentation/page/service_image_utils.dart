bool _isHttpScheme(String? value) {
  if (value == null || value.isEmpty) return false;

  // Intenta hacer parse de la URI
  final trimmed = value.trim();
  try {
    final uri = Uri.parse(trimmed);
    return uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    // Si Uri.parse falla, intenta escapar la URL
    try {
      final escaped = Uri.encodeFull(trimmed);
      final uri = Uri.parse(escaped);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }
}

/// Returns the first URL in [candidates] that has a supported HTTP/HTTPS scheme.
String? firstValidNetworkImage(List<String>? candidates) {
  if (candidates == null || candidates.isEmpty) return null;
  for (final candidate in candidates) {
    if (candidate.isEmpty) continue;
    if (_isHttpScheme(candidate)) {
      return candidate.trim();
    }
  }
  return null;
}

bool isValidNetworkImageUrl(String? value) => _isHttpScheme(value);
