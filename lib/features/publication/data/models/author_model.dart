import '../../domain/entities/author.dart';

class AuthorModel extends Author {
  const AuthorModel({
    super.id,
    required super.displayName,
    super.orcid,
    super.affiliations = const [],
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    return AuthorModel(
      id: author['id'] as String?,
      displayName: (author['display_name'] as String?) ?? 'Unknown Author',
      orcid: author['orcid'] as String?,
      affiliations: _parseAffiliations(json),
    );
  }

  static List<String> _parseAffiliations(Map<String, dynamic> authorship) {
    final raw = authorship['raw_affiliation_strings'] as List<dynamic>?;
    if (raw != null && raw.isNotEmpty) {
      return raw
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final institutions = authorship['institutions'] as List<dynamic>? ?? [];
    return institutions
        .whereType<Map<String, dynamic>>()
        .map((i) => i['display_name'] as String?)
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }
}
