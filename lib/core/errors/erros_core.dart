class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: [$code] $message';
}

// Specific exception types
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    String? code,
    super.details,
    super.stackTrace,
  }) : super(
          code: code ?? 'NETWORK_ERROR',
        );
}

class FileOperationException extends AppException {
  FileOperationException({
    required super.message,
    String? code,
    super.details,
    super.stackTrace,
  }) : super(
          code: code ?? 'FILE_ERROR',
        );
}

class PrintingException extends AppException {
  PrintingException({
    required super.message,
    String? code,
    super.details,
    super.stackTrace,
  }) : super(
          code: code ?? 'PRINT_ERROR',
        );
}

// Add these new exception types to your existing file

class StorageException extends AppException {
  StorageException({
    required super.message,
    String? code,
    super.details,
    super.stackTrace,
  }) : super(
          code: code ?? 'STORAGE_ERROR',
        );
}

class QueueException extends AppException {
  QueueException({
    required super.message,
    String? code,
    super.details,
    super.stackTrace,
  }) : super(
          code: code ?? 'QUEUE_ERROR',
        );
}