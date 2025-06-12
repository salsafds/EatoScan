import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:eatoscan/edit_produk.dart';
import 'produk_model.dart';

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
    showDialog(
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
                  } catch (e) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    ).then((value) {
      if (mounted) {
        if (produkBox.values.length < produkBox.length ||
            selectedIndex == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil: Produk berhasil dihapus.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (selectedIndex != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Penghapusan dibatalkan.'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal: Terjadi kesalahan saat menghapus produk.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    });
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
                          width: 800,
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EditProdukPage(
                                              index: selectedIndex!,
                                              produk: produk!,
                                            ),
                                      ),
                                    ).then((result) {
                                      if (result == true && mounted) {
                                        setState(
                                          () {},
                                        ); // Refresh the list after editing
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Berhasil: Produk berhasil diubah.',
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

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

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

class _DataCell extends StatelessWidget {
  final String value;
  const _DataCell(this.value);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Text(value, overflow: TextOverflow.ellipsis),
    );
  }
}
