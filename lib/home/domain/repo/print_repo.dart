import 'package:printing_app/home/domain/entity/print_entity.dart';


abstract class FileRepository {
  Future<List<PrintFileEntity>> pickFiles();
}