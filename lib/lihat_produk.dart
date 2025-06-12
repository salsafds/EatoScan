import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';

import 'produk_model.dart';
import 'edit_produk.dart';

class LihatProdukPage extends StatefulWidget {
  const LihatProdukPage({super.key});

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
    showDialog<void>(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menghapus produk ini?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  try {
                    produkBox.deleteAt(index);
                    setState(() {
                      selectedIndex = null;
                    });
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Berhasil: Produk berhasil dihapus.'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Gagal: Terjadi kesalahan saat menghapus produk: $e',
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
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
      backgroundColor: const Color(0xFFE85D04),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed('/crudAdmin');
                      },
                    ),
                  ),
                  const Center(
                    child: Text(
                      'EatoScan',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
                          width: 1350,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: produkList.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Container(
                                  color: const Color(0xFFDDDDDD),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 8,
                                  ),
                                  child: const Row(
                                    children: [
                                      HeaderCell('Gambar'),
                                      HeaderCell('Nama Produk'),
                                      HeaderCell('Kode Produk'),
                                      HeaderCell('Nutrisi'),
                                      HeaderCell('Potensi Risiko'),
                                      HeaderCell('Kategori'),
                                      HeaderCell('Preferensi Nutrisi'),
                                      HeaderCell('Takaran Kemasan (g)'),
                                      HeaderCell('Sajian per Kemasan (g)'),
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
                                            ? Colors.yellow.shade200
                                            : null,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        DataCell(
                                          produk.gambarPath != null
                                              ? Image.file(
                                                File(produk.gambarPath!),
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Text(
                                                      'Gambar error',
                                                    ),
                                              )
                                              : const Text('Tidak ada gambar'),
                                        ),
                                        DataCell(Text(produk.nama)),
                                        DataCell(Text(produk.kode)),
                                        DataCell(
                                          SizedBox(
                                            width: 150,
                                            child: Text(
                                              produk.nutrisi,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 150,
                                            child: Text(
                                              produk.risiko,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(produk.tambahan)),
                                        DataCell(
                                          SizedBox(
                                            width: 150,
                                            child: Text(
                                              produk.preferensiNutrisi.entries
                                                  .where((entry) => entry.value)
                                                  .map(
                                                    (entry) => entry.key
                                                        .replaceAll('_', ' '),
                                                  )
                                                  .join(', '),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            produk.takaranKemasan.toString(),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            produk.sajianPerKemasan.toString(),
                                          ),
                                        ),
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
                                    final produk =
                                        produkBox.getAt(selectedIndex!)!;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EditProdukPage(
                                              index: selectedIndex!,
                                              produk: produk,
                                            ),
                                      ),
                                    ).then((result) {
                                      if (result == true && mounted) {
                                        setState(() {});
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Sukses: Produk berhasil diubah.',
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                    });
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

class HeaderCell extends StatelessWidget {
  final String label;

  const HeaderCell(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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

class DataCell extends StatelessWidget {
  final Widget content;

  const DataCell(this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 150, child: content);
  }
}
