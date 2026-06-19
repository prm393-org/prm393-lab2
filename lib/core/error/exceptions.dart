/// Exceptions ném ra từ tầng data (datasource / api client).
library;

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Không có kết nối mạng']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Lỗi đọc/ghi dữ liệu cục bộ']);
}

class ParsingException implements Exception {
  final String message;
  const ParsingException([this.message = 'Dữ liệu trả về không hợp lệ']);
}
