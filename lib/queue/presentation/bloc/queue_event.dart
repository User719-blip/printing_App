import 'package:equatable/equatable.dart';
import 'package:printing_app/home/domain/entity/print_entity.dart';

abstract class QueueEvent extends Equatable {
  const QueueEvent();
  
  @override
  List<Object?> get props => [];
}

class SubmitPrintJobEvent extends QueueEvent {
  final PrintFileEntity file;
  final int copies;
  
  const SubmitPrintJobEvent({
    required this.file,
    required this.copies,
  });
  
  @override
  List<Object?> get props => [file, copies];
}

class TrackPrintJobEvent extends QueueEvent {
  final String jobId;
  
  const TrackPrintJobEvent(this.jobId);
  
  @override
  List<Object?> get props => [jobId];
}

class CancelPrintJobEvent extends QueueEvent {
  final String jobId;
  
  const CancelPrintJobEvent(this.jobId);
  
  @override
  List<Object?> get props => [jobId];
}