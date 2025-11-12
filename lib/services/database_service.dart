import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/photo_entry.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('windowpane.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE photos (
      id $idType,
      imagePath $textType,
      description $textType,
      timestamp $textType,
      latitude $realType,
      longitude $realType,
      address $textType,
      temperature $realType,
      weatherCondition $textType
    )
    ''');
  }

  Future<int> insertPhoto(PhotoEntry photo) async {
    final db = await database;
    return await db.insert('photos', photo.toMap());
  }

  Future<List<PhotoEntry>> getAllPhotos() async {
    final db = await database;
    final result = await db.query('photos', orderBy: 'timestamp DESC');
    return result.map((map) => PhotoEntry.fromMap(map)).toList();
  }

  Future<int> deletePhoto(int id) async {
    final db = await database;
    return await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updatePhoto(PhotoEntry photo) async {
    final db = await database;
    return await db.update(
      'photos',
      photo.toMap(),
      where: 'id = ?',
      whereArgs: [photo.id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}