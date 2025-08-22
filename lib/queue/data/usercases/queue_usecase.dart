import 'package:printing_app/home/domain/entity/print_entity.dart';
import 'package:printing_app/queue/domain/entity/printjobentity.dart';
import 'package:printing_app/queue/domain/repo/queue_repo.dart';

class SubmitPrintJobUseCase {
  final QueueRepository repository;
  
  SubmitPrintJobUseCase(this.repository);
  
  Future<PrintJobEntity> call({
    required PrintFileEntity file,
    required int copies,
  }) async {
    return await repository.submitPrintJob(
      file: file,
      copies: copies,
    );
  }
}

class GetJobUpdatesUseCase {
  final QueueRepository repository;
  
  GetJobUpdatesUseCase(this.repository);
  
  Stream<PrintJobEntity> call(String jobId) {
    return repository.getJobUpdates(jobId);
  }
}

class CancelPrintJobUseCase {
  final QueueRepository repository;
  
  CancelPrintJobUseCase(this.repository);
  
  Future<void> call(String jobId) async {
    await repository.cancelPrintJob(jobId);
  }
}