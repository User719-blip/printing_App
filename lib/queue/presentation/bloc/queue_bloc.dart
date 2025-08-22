import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing_app/core/errors/error_handlers.dart';
import 'package:printing_app/queue/data/usercases/queue_usecase.dart';
import 'package:printing_app/queue/domain/entity/printjobentity.dart';
import 'queue_event.dart';
import 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final SubmitPrintJobUseCase submitPrintJobUseCase;
  final GetJobUpdatesUseCase getJobUpdatesUseCase;
  final CancelPrintJobUseCase cancelPrintJobUseCase;
  
  StreamSubscription<PrintJobEntity>? _jobSubscription;
  
  QueueBloc({
    required this.submitPrintJobUseCase,
    required this.getJobUpdatesUseCase,
    required this.cancelPrintJobUseCase,
  }) : super(QueueInitial()) {
    on<SubmitPrintJobEvent>(_onSubmitPrintJob);
    on<TrackPrintJobEvent>(_onTrackPrintJob);
    on<CancelPrintJobEvent>(_onCancelPrintJob);
    
    // Internal event handlers for the subscription
    on<_JobUpdateEvent>(_onJobUpdate);
    on<_JobErrorEvent>(_onJobError);
  }
  
  Future<void> _onSubmitPrintJob(
    SubmitPrintJobEvent event,
    Emitter<QueueState> emit,
  ) async {
    emit(QueueSubmitting());
    
    try {
    //  print('Submitting print job: ${event.file.name}');
      final job = await submitPrintJobUseCase(
        file: event.file,
        copies: event.copies,
      );
    //  print('Job submitted successfully, emitting QueueSubmitted state');
      emit(QueueSubmitted(job));
      
      // Automatically start tracking the job
      add(TrackPrintJobEvent(job.id));
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace);
      final failure = ErrorHandler.handleException(e, stackTrace);
      final message = ErrorHandler.getUserFriendlyMessage(failure);
      emit(QueueError(message));
    }
  }
  
  Future<void> _onTrackPrintJob(
    TrackPrintJobEvent event,
    Emitter<QueueState> emit,
  ) async {
    // Cancel existing subscription if any
    await _jobSubscription?.cancel();
    
    try {
      _jobSubscription = getJobUpdatesUseCase(event.jobId).listen(
        (job) => add(_JobUpdateEvent(job)),
        onError: (error) => add(_JobErrorEvent(error.toString())),
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace);
      final failure = ErrorHandler.handleException(e, stackTrace);
      final message = ErrorHandler.getUserFriendlyMessage(failure);
      emit(QueueError(message));
    }
  }
  
  Future<void> _onCancelPrintJob(
    CancelPrintJobEvent event,
    Emitter<QueueState> emit,
  ) async {
    try {
      await cancelPrintJobUseCase(event.jobId);
      // The status update will come through the subscription
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace);
      final failure = ErrorHandler.handleException(e, stackTrace);
      final message = ErrorHandler.getUserFriendlyMessage(failure);
      emit(QueueError(message));
    }
  }
  
  void _onJobUpdate(_JobUpdateEvent event, Emitter<QueueState> emit) {
    emit(QueueTracking(event.job));
  }
  
  void _onJobError(_JobErrorEvent event, Emitter<QueueState> emit) {
    emit(QueueError(event.message));
  }
  
  @override
  Future<void> close() {
    _jobSubscription?.cancel();
    return super.close();
  }
}

// Private events for subscription handling
class _JobUpdateEvent extends QueueEvent {
  final PrintJobEntity job;
  
  const _JobUpdateEvent(this.job);
  
  @override
  List<Object?> get props => [job];
}

class _JobErrorEvent extends QueueEvent {
  final String message;
  
  const _JobErrorEvent(this.message);
  
  @override
  List<Object?> get props => [message];
}