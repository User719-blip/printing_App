import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class FileFailure extends Failure {
  const FileFailure({
    required super.message,
    String? code,
  }) : super(
          code: code ?? 'FILE_FAILURE',
        );
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    String? code,
  }) : super(
          code: code ?? 'NETWORK_FAILURE',
        );
}

class PrintFailure extends Failure {
  const PrintFailure({
    required super.message,
    String? code,
  }) : super(
          code: code ?? 'PRINT_FAILURE',
        );
}

// Add these new failure types to your existing file

class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    String? code,
  }) : super(
          code: code ?? 'STORAGE_FAILURE',
        );
}

class QueueFailure extends Failure {
  const QueueFailure({
    required super.message,
    String? code,
  }) : super(
          code: code ?? 'QUEUE_FAILURE',
        );
}


class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error occurred',
    String? code,
  }) : super(
          code: code ?? 'UNKNOWN_FAILURE',
        );
}