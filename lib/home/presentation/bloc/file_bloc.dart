import 'package:printing_app/core/errors/error_handlers.dart';
import 'package:printing_app/home/domain/entity/print_entity.dart';
import 'package:printing_app/home/domain/repo/print_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'file_event.dart';
import 'file_state.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  final FileRepository fileRepository;
  final List<PrintFileEntity> _files = [];
  
  FileBloc({required this.fileRepository}) : super(FileInitial()) {
    on<FilePickRequested>(_onFilePickRequested);
    on<FileRemoved>(_onFileRemoved);
    on<AllFilesCleared>(_onAllFilesCleared);
  }
  
  Future<void> _onFilePickRequested(
    FilePickRequested event,
    Emitter<FileState> emit,
  ) async {
    emit(FileLoading());
    try {
      final pickedFiles = await fileRepository.pickFiles();
      if (pickedFiles.isNotEmpty) {
        _files.addAll(pickedFiles);
        emit(FileLoaded(List.from(_files)));
      } else {
        emit(FileLoaded(List.from(_files)));
      }
    } catch (e, stackTrace) {
      // Log the error
      ErrorHandler.logError(e, stackTrace);
      
      // Convert to user-friendly message
      final failure = ErrorHandler.handleException(e, stackTrace);
      final userMessage = ErrorHandler.getUserFriendlyMessage(failure);
      
      emit(FileError(userMessage));
    }
  }
  
  // Other event handlers remain the same
  void _onFileRemoved(FileRemoved event, Emitter<FileState> emit) {
    if (event.index >= 0 && event.index < _files.length) {
      _files.removeAt(event.index);
      emit(FileLoaded(List.from(_files)));
    }
  }
  
  void _onAllFilesCleared(AllFilesCleared event, Emitter<FileState> emit) {
    _files.clear();
    emit(FileLoaded(List.from(_files)));
  }
}