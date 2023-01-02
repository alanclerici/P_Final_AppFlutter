import 'package:path/path.dart';
import 'package:smart_home/datoDB.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  static final Db instance = Db._init();

  static Database? _database;

  Db._init();

  final String tablaDatos = 'datosBroker';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('datosBroker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreateDB);
  }

  Future _onCreateDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tablaDatos(
    id INTEGER PRIMARY KEY,
    ip TEXT,
    clave TEXT
    )
    ''');
  }

  Future<void> insert(DatoDB item) async {
    final db = await instance.database;
    await db.insert(tablaDatos, item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DatoDB>> getAllItems() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tablaDatos);

    return List.generate(maps.length, (i) {
      return DatoDB(
        id: maps[i]['id'],
        ip: maps[i]['ip'],
        clave: maps[i]['clave'],
      );
    });
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tablaDatos,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> update(DatoDB item) async {
    final db = await instance.database;
    return await db.update(
      tablaDatos,
      item.toMap(),
      where: "id=?",
      whereArgs: [item.id],
    );
  }
}
