bool _isHttpScheme(String? value) {
  if (value == null) return false;
  final uri = Uri.tryParse(value);
  return uri != null &&
      uri.hasScheme &&
      (uri.scheme == 'http' || uri.scheme == 'https');
}

/// Returns the first URL in [candidates] that has a supported HTTP/HTTPS scheme.
String? firstValidNetworkImage(List<String>? candidates) {
  if (candidates == null) return null;
  for (final candidate in candidates) {
    if (_isHttpScheme(candidate)) {
      return candidate;
    }
  }
  return null;
}

bool isValidNetworkImageUrl(String? value) => _isHttpScheme(value);
