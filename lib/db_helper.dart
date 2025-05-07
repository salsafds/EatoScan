import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'data_nutrisi.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table produk/nutrisi
    await db.execute('''
      CREATE TABLE nutrisi (
        id_produk INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        kode TEXT,
        nutrisi TEXT,
        tambahan TEXT,
        risiko TEXT
      )
    ''');

    // Table user
    await db.execute('''
      CREATE TABLE user (
        id_user INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        usia INTEGER,
        gender TEXT CHECK(gender IN ('Male', 'Female', 'Other')),
        PENYAKIT TEXT
      )
    ''');
  }

  // ✅ Cek login
  Future<bool> checkLogin(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'user',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  // ✅ Tambah user (register)
  Future<int> addUser({
    required String username,
    required String email,
    required String password,
    int? usia,
    String? gender,
    String? penyakit,
  }) async {
    final db = await database;
    final data = {
      'username': username,
      'email': email,
      'password': password,
      'usia': usia,
      'gender': gender,
      'PENYAKIT': penyakit,
    };
    return await db.insert('user', data);
  }

  // ✅ Tambah produk/nutrisi
  Future<int> addProduk({
    required String nama,
    required String kode,
    required String nutrisi,
    required String tambahan,
    required String risiko,
  }) async {
    final db = await database;
    final data = {
      'nama': nama,
      'kode': kode,
      'nutrisi': nutrisi,
      'tambahan': tambahan,
      'risiko': risiko,
    };
    return await db.insert('nutrisi', data);
  }

  // ✅ Ambil semua data produk
  Future<List<Map<String, dynamic>>> getAllProduk() async {
    final db = await database;
    return await db.query('nutrisi');
  }

  // ✅ Hapus produk berdasarkan id
  Future<int> deleteProduk(int idProduk) async {
    final db = await database;
    return await db.delete(
      'nutrisi',
      where: 'id_produk = ?',
      whereArgs: [idProduk],
    );
  }

  // ✅ Update produk berdasarkan id
  Future<int> updateProduk({
    required int idProduk,
    required String nama,
    required String kode,
    required String nutrisi,
    required String tambahan,
    required String risiko,
  }) async {
    final db = await database;
    final data = {
      'nama': nama,
      'kode': kode,
      'nutrisi': nutrisi,
      'tambahan': tambahan,
      'risiko': risiko,
    };
    return await db.update(
      'nutrisi',
      data,
      where: 'id_produk = ?',
      whereArgs: [idProduk],
    );
  }
}
