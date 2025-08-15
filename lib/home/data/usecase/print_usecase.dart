import 'package:printing_app/home/domain/entity/print_entity.dart';
import 'package:printing_app/home/domain/repo/print_repo.dart';



class PickFilesUseCase {
  final FileRepository repository;
  
  PickFilesUseCase(this.repository);
  
  Future<List<PrintFileEntity>> call() async {
    try {
      return await repository.pickFiles();
    } catch (e) {
      rethrow; // Let the error handler deal with this
    }
  }
}