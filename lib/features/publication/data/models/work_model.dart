import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/abstract_decoder.dart';
import '../../domain/entities/work.dart';
import 'author_model.dart';

class WorkModel extends Work {
  const WorkModel({
    required super.id,
    super.doi,
    required super.title,
    super.publicationYear,
    required super.citedByCount,
    required super.authors,
    super.sourceName,
    super.abstract_,
    required super.isOpenAccess,
  });

  factory WorkModel.fromJson(Map<String, dynamic> json) {
    try {
      final authorships = json['authorships'] as List<dynamic>? ?? [];
      final authors = authorships
          .whereType<Map<String, dynamic>>()
          .map(AuthorModel.fromJson)
          .toList();

      final primaryLocation =
          json['primary_location'] as Map<String, dynamic>?;
      final source = primaryLocation?['source'] as Map<String, dynamic>?;

      final openAccess = json['open_access'] as Map<String, dynamic>?;

      final abstractIndex =
          json['abstract_inverted_index'] as Map<String, dynamic>?;

      return WorkModel(
        id: json['id'] as String? ?? '',
        doi: json['doi'] as String?,
        title: (json['title'] as String?) ??
            (json['display_name'] as String?) ??
            'Untitled',
        publicationYear: json['publication_year'] as int?,
        citedByCount: json['cited_by_count'] as int? ?? 0,
        authors: authors,
        sourceName: source?['display_name'] as String?,
        abstract_: AbstractDecoder.reconstruct(abstractIndex),
        isOpenAccess: openAccess?['is_oa'] as bool? ?? false,
      );
    } catch (e) {
      throw ParsingException('Failed to parse work: $e');
    }
  }
}
