import 'dart:async';

import 'package:printing_app/core/errors/erros_core.dart';
import 'package:printing_app/home/domain/entity/print_entity.dart';
import 'package:printing_app/queue/data/datasource/remote_datasource.dart';
import 'package:printing_app/queue/domain/entity/printjobentity.dart';
import 'package:printing_app/queue/domain/repo/queue_repo.dart';

class QueueRepositoryImpl implements QueueRepository {
  @override
  Future<PrintJobEntity> submitPrintJob({
    required PrintFileEntity file,
    required int copies,
  }) async {
    try {
      print(
        'Starting file upload: ${file.name}, size: ${file.bytes?.length ?? 0} bytes',
      );

      // Check if bytes are available
      if (file.bytes == null || file.bytes!.isEmpty) {
        throw FileOperationException(message: 'File bytes are empty or null');
      }

      // 1. Upload file to Supabase Storage
      final String fileUrl = await SupabaseService.uploadFile(
        file.bytes ?? [],
        file.name,
      );

      // 2. Create print job in Supabase
      final Map<String, dynamic> jobData = await SupabaseService.createPrintJob(
        fileName: file.name,
        fileUrl: fileUrl,
        copies: copies,
      );

      // 3. Get initial queue position
      final int queuePosition = await SupabaseService.getQueuePosition(
        jobData['id'],
      );

      // 4. Convert to entity
      return PrintJobEntity(
        id: jobData['id'],
        fileName: jobData['file_name'],
        fileUrl: jobData['file_url'],
        copies: jobData['copies'],
        status: _mapStringToStatus(jobData['status']),
        createdAt: DateTime.parse(jobData['created_at']),
        queuePosition: queuePosition,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;

      throw PrintingException(
        message: 'Failed to submit print job: ${e.toString()}',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Stream<PrintJobEntity> getJobUpdates(String jobId) {
    return SupabaseService.getJobUpdates(jobId).asyncMap((jobData) async {
      // Get current queue position with each update
      final int queuePosition = jobData['status'] == 'pending'
          ? await SupabaseService.getQueuePosition(jobId)
          : 0;

      return PrintJobEntity(
        id: jobData['id'],
        fileName: jobData['file_name'],
        fileUrl: jobData['file_url'],
        copies: jobData['copies'],
        status: _mapStringToStatus(jobData['status']),
        createdAt: DateTime.parse(jobData['created_at']),
        queuePosition: queuePosition,
      );
    });
  }

  @override
  Future<void> cancelPrintJob(String jobId) async {
    try {
      await SupabaseService.cancelPrintJob(jobId);
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to map string status to enum
  PrintJobStatus _mapStringToStatus(String status) {
    switch (status) {
      case 'pending':
        return PrintJobStatus.pending;
      case 'printing':
        return PrintJobStatus.printing;
      case 'completed':
        return PrintJobStatus.completed;
      case 'failed':
        return PrintJobStatus.failed;
      case 'canceled':
        return PrintJobStatus.canceled;
      default:
        return PrintJobStatus.pending;
    }
  }
}
