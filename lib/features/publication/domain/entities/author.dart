import 'package:equatable/equatable.dart';

class Author extends Equatable {
  final String? id;
  final String displayName;
  final String? orcid;
  final List<String> affiliations;

  const Author({
    this.id,
    required this.displayName,
    this.orcid,
    this.affiliations = const [],
  });

  @override
  List<Object?> get props => [id, displayName, orcid, affiliations];
}
