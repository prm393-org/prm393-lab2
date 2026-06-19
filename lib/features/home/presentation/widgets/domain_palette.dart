import 'package:flutter/material.dart';

/// Bảng màu cố định cho từng domain của OpenAlex — dùng chung
/// giữa topic card và biểu đồ treemap để màu nhất quán.
class DomainPalette {
  DomainPalette._();

  static const Map<String, Color> _byDomain = {
    'Physical Sciences': Color(0xFF2563EB),
    'Life Sciences': Color(0xFF16A34A),
    'Health Sciences': Color(0xFFDC2626),
    'Social Sciences': Color(0xFF7C3AED),
  };

  static const List<Color> _fallback = [
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFDC2626),
    Color(0xFF7C3AED),
    Color(0xFFEA580C),
    Color(0xFF0891B2),
    Color(0xFFCA8A04),
    Color(0xFFDB2777),
  ];

  static Color of(String? domain) {
    if (domain == null) return _fallback.first;
    return _byDomain[domain] ?? _fallback[domain.hashCode.abs() % _fallback.length];
  }
}
