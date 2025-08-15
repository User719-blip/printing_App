import 'dart:developer' as developer;
import 'dart:io';

import 'package:printing_app/core/errors/erros_core.dart';
import 'package:printing_app/core/errors/faliure.dart';

class ErrorHandler {
  // Convert exceptions to failures
  // Update the handleException method

  static Failure handleException(dynamic exception, [StackTrace? stackTrace]) {
    developer.log(
      'Exception caught: $exception',
      error: exception,
      stackTrace: stackTrace,
    );

    if (exception is FileOperationException) {
      return FileFailure(message: exception.message, code: exception.code);
    } else if (exception is NetworkException) {
      return NetworkFailure(message: exception.message, code: exception.code);
    } else if (exception is PrintingException) {
      return PrintFailure(message: exception.message, code: exception.code);
    } else if (exception is StorageException) {
      return StorageFailure(message: exception.message, code: exception.code);
    } else if (exception is QueueException) {
      return QueueFailure(message: exception.message, code: exception.code);
    } else if (exception is SocketException) {
      return NetworkFailure(
        message: 'Network error: ${exception.message}',
        code: 'SOCKET_ERROR',
      );
    } else if (exception is HttpException) {
      return NetworkFailure(
        message: 'HTTP error: ${exception.message}',
        code: 'HTTP_ERROR',
      );
    } else {
      return UnknownFailure(
        message: exception?.toString() ?? 'An unknown error occurred',
      );
    }
  }

  // Update the getUserFriendlyMessage method
  static String getUserFriendlyMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (FileFailure):
        return 'There was a problem with the file operation. Please try again.';
      case const (NetworkFailure):
        return 'Network connection issue. Please check your internet connection.';
      case const (PrintFailure):
        return 'Printing failed. Please check your printer connection.';
      case const (StorageFailure):
        return 'Failed to upload your file. Please try again.';
      case const (QueueFailure):
        return 'There was an issue with the print queue. Please try again.';
      default:
        return 'Something went wrong. Please try again later.';
    }
  }

  // Log errors
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    developer.log('Error: $error', error: error, stackTrace: stackTrace);
    // Add your preferred logging service here
  }

  
  
}
