import 'package:hive/hive.dart';
import 'user_model.dart';
import 'produk_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  final Box<UserModel> _userBox = Hive.box<UserModel>('users');
  final Box<ProdukModel> _produkBox = Hive.box<ProdukModel>('produk');

  // ✅ Cek login
  Future<bool> checkLogin(String username, String password) async {
    final user = _userBox.get(username);
    return user != null && user.password == password;
  }

  // ✅ Tambah user (register)
  Future<void> addUser({
    required String username,
    required String email,
    required String password,
    int? usia,
    String? gender,
    String? penyakit,
  }) async {
    final newUser = UserModel(
      username: username,
      email: email,
      password: password,
      usia: usia,
      gender: gender,
      penyakit: penyakit,
    );
    await _userBox.put(email, newUser);
  }

  // ✅ Tambah produk/nutrisi
  Future<void> addProduk({
    required String nama,
    required String kode,
    required String nutrisi,
    required String tambahan,
    required String risiko,
  }) async {
    final newProduk = ProdukModel(
      nama: nama,
      kode: kode,
      nutrisi: nutrisi,
      tambahan: tambahan,
      risiko: risiko,
    );
    await _produkBox.add(newProduk);
  }

  // ✅ Ambil semua data produk
  List<ProdukModel> getAllProduk() {
    return _produkBox.values.toList();
  }

  // ✅ Hapus produk berdasarkan id
  Future<void> deleteProduk(int index) async {
    await _produkBox.deleteAt(index);
  }

  // ✅ Update produk berdasarkan id
  Future<void> updateProduk(int index, ProdukModel updatedProduk) async {
    await _produkBox.putAt(index, updatedProduk);
  }
}
