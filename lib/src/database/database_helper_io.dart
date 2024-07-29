import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

Future<Database> initDatabase() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  final dbPath = join(appDocumentDir.path, 'my_database.db');
  return await databaseFactoryIo.openDatabase(dbPath);
}
