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
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    ).then((confirm) {
      if (confirm == true) {
        produkBox.deleteAt(index);
        setState(() {
          selectedIndex = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final produkList = produkBox.values.toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER MELENGKUNG KIRI KANAN
          ClipPath(
            clipper: UShapeClipper(),
            child: Container(
              color: const Color(0xFFFF6B00),
              height: 120,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'EatoScan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Data Produk',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed:
                    selectedIndex != null
                        ? () {
                          final produk = produkBox.getAt(selectedIndex!);
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
          const SizedBox(height: 16),
          // TABEL
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800,
                child: ListView.builder(
                  itemCount: produkList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // HEADER
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
                                  ? Colors.yellow.shade700.withOpacity(0.7)
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
        ],
      ),
    );
  }
}

// WIDGET HEADER TABEL
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

// WIDGET DATA TABEL
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

// CLIPPER UNTUK MELENGKUNG ∩ (kiri dan kanan bawah)
class UShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40); // kiri turun
    path.quadraticBezierTo(0, size.height, 40, size.height); // lengkung kiri

    path.lineTo(size.width - 40, size.height); // bawah
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - 40,
    ); // lengkung kanan

    path.lineTo(size.width, 0); // kanan atas
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
