import 'package:equatable/equatable.dart';

abstract class FileEvent extends Equatable {
  const FileEvent();
  
  @override
  List<Object> get props => [];
}

class FilePickRequested extends FileEvent {}

class FileRemoved extends FileEvent {
  final int index;
  
  const FileRemoved(this.index);
  
  @override
  List<Object> get props => [index];
}

class AllFilesCleared extends FileEvent {}