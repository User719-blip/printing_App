import 'package:equatable/equatable.dart';
import 'package:printing_app/queue/domain/entity/printjobentity.dart';

abstract class QueueState extends Equatable {
  const QueueState();
  
  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueState {}

class QueueSubmitting extends QueueState {}

class QueueSubmitted extends QueueState {
  final PrintJobEntity job;
  
  const QueueSubmitted(this.job);
  
  @override
  List<Object?> get props => [job];
}

class QueueTracking extends QueueState {
  final PrintJobEntity job;
  
  const QueueTracking(this.job);
  
  @override
  List<Object?> get props => [job];
}

class QueueError extends QueueState {
  final String message;
  
  const QueueError(this.message);
  
  @override
  List<Object?> get props => [message];
}