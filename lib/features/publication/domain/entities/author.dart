import 'package:equatable/equatable.dart';

class Author extends Equatable {
  final String? id;
  final String displayName;
  final String? orcid;

  const Author({this.id, required this.displayName, this.orcid});

  @override
  List<Object?> get props => [id, displayName, orcid];
}
