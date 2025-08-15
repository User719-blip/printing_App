import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:printing_app/core/errors/erros_core.dart';
import 'package:printing_app/home/domain/entity/print_entity.dart';
import 'package:printing_app/home/domain/repo/print_repo.dart';

class FileRepositoryImpl implements FileRepository {
  @override
  Future<List<PrintFileEntity>> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: true,
      );
      
      if (result == null) {
        return [];
      }
      
      return result.files.map((file) {
        // On web, file.path will be null, so handle differently
        final fileName = file.name;
        final fileExtension = path.extension(fileName).replaceAll('.', '');
        
        return PrintFileEntity(
          // On web, we store the bytes in memory instead of a path
          path: kIsWeb ? '' : (file.path ?? ''),
          name: fileName,
          extension: fileExtension,
          addedAt: DateTime.now(),
          // Store bytes for web preview
          bytes: file.bytes,
        );
      }).toList();
    } catch (e, stackTrace) {
      // Convert to domain-specific exception
      throw FileOperationException(
        message: 'Failed to pick files: ${e.toString()}',
        details: e,
        stackTrace: stackTrace,
      );
    }
  }
}