import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

Future<Database> initDatabase() async {
  return await databaseFactoryWeb.openDatabase('my_database.db');
}
