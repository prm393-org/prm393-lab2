import 'package:equatable/equatable.dart';

/// Failures trả về tầng domain/presentation (kết hợp với dartz `Either`).
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Không có kết nối mạng']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Lỗi dữ liệu cục bộ']);
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Dữ liệu không hợp lệ']);
}
