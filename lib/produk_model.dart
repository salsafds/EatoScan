import 'package:hive/hive.dart';

part 'produk_model.g.dart';

@HiveType(typeId: 1)
class ProdukModel extends HiveObject {
  @HiveField(0)
  String nama;

  @HiveField(1)
  String kode;

  @HiveField(2)
  String nutrisi;

  @HiveField(3)
  String tambahan;

  @HiveField(4)
  String risiko;

  ProdukModel({
    required this.nama,
    required this.kode,
    required this.nutrisi,
    required this.tambahan,
    required this.risiko,
  });

  get gambarPath => null;

  get kategori => null;
}
