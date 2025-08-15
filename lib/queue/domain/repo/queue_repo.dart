import 'package:printing_app/home/domain/entity/print_entity.dart';
import 'package:printing_app/queue/domain/entity/printjobentity.dart';

abstract class QueueRepository {
  // Submit a new print job
  Future<PrintJobEntity> submitPrintJob({
    required PrintFileEntity file,
    required int copies,
  });
  
  // Get real-time updates for a specific print job
  Stream<PrintJobEntity> getJobUpdates(String jobId);
  
  // Cancel a print job
  Future<void> cancelPrintJob(String jobId);
}