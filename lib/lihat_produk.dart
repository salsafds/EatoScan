import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'produk_model.dart';

class LihatProdukPage extends StatefulWidget {
  const LihatProdukPage({Key? key}) : super(key: key);

  @override
  State<LihatProdukPage> createState() => _LihatProdukPageState();
}

class _LihatProdukPageState extends State<LihatProdukPage> {
  late Box<ProdukModel> produkBox;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    produkBox = Hive.box<ProdukModel>('produk');
  }

  void hapusProduk(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menghapus produk ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  produkBox.deleteAt(index);
                  setState(() {
                    selectedIndex = null;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produkList = produkBox.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE85D04), // warna oranye
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: const Center(
                child: Text(
                  'EatoScan',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Data Produk',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 800,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: produkList.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // Header tabel
                                return Container(
                                  color: const Color(0xFFDDDDDD),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: const [
                                      _HeaderCell('Nama Produk'),
                                      _HeaderCell('Kode Produk'),
                                      _HeaderCell('Nutrisi'),
                                      _HeaderCell('Potensi Risiko'),
                                      _HeaderCell('Kategori'),
                                    ],
                                  ),
                                );
                              } else {
                                final produk = produkList[index - 1];
                                final isSelected = selectedIndex == index - 1;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index - 1;
                                    });
                                  },
                                  child: Container(
                                    color:
                                        isSelected
                                            ? Colors.yellow.shade700
                                                .withOpacity(0.7)
                                            : null,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        _DataCell(produk.nama),
                                        _DataCell(produk.kode),
                                        _DataCell(produk.nutrisi),
                                        _DataCell(produk.risiko),
                                        _DataCell(produk.tambahan),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed:
                              selectedIndex != null
                                  ? () {
                                    final produk = produkBox.getAt(
                                      selectedIndex!,
                                    );
                                    Navigator.pushNamed(
                                      context,
                                      '/ubah_produk',
                                      arguments: {
                                        'index': selectedIndex,
                                        'produk': produk,
                                      },
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF225840),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Ubah',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed:
                              selectedIndex != null
                                  ? () => hapusProduk(selectedIndex!)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF225840),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Komponen header kolom tabel
class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Komponen isi data tabel
class _DataCell extends StatelessWidget {
  final String value;
  const _DataCell(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: Text(value, overflow: TextOverflow.ellipsis),
    );
  }
}
