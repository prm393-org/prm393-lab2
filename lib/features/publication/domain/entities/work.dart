import 'package:equatable/equatable.dart';

import 'author.dart';

class Work extends Equatable {
  final String id;
  final String? doi;
  final String title;
  final int? publicationYear;
  final int citedByCount;
  final List<Author> authors;
  final String? sourceName;
  final String? abstract_;
  final bool isOpenAccess;

  const Work({
    required this.id,
    this.doi,
    required this.title,
    this.publicationYear,
    required this.citedByCount,
    required this.authors,
    this.sourceName,
    this.abstract_,
    required this.isOpenAccess,
  });

  @override
  List<Object?> get props => [id];
}
