import '../../domain/entities/author.dart';

class AuthorModel extends Author {
  const AuthorModel({super.id, required super.displayName, super.orcid});

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    return AuthorModel(
      id: author['id'] as String?,
      displayName: (author['display_name'] as String?) ?? 'Unknown Author',
      orcid: author['orcid'] as String?,
    );
  }
}
