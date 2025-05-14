import 'package:hive/hive.dart';
import 'produk_model.dart';

class ProdukService {
  final Box<ProdukModel> _box = Hive.box<ProdukModel>('produk');

  Future<void> tambahProduk(ProdukModel produk) async {
    await _box.add(produk);
  }

  List<ProdukModel> ambilSemuaProduk() {
    return _box.values.toList();
  }

  Future<void> updateProduk(int index, ProdukModel produkBaru) async {
    await _box.putAt(index, produkBaru);
  }

  Future<void> hapusProduk(int index) async {
    await _box.deleteAt(index);
  }
}
