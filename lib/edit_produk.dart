import 'package:flutter/material.dart';
import 'package:eatoscan/produk_model.dart';
import 'package:hive/hive.dart';

class EditProdukPage extends StatefulWidget {
  final int index;
  final ProdukModel produk;

  const EditProdukPage({super.key, required this.index, required this.produk});

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  late TextEditingController _namaController;
  late TextEditingController _kodeController;
  late List<TextEditingController> _nutrisiNamaControllers;
  late List<TextEditingController> _nutrisiBeratControllers;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.produk.nama);
    _kodeController = TextEditingController(text: widget.produk.kode);

    _nutrisiNamaControllers = [];
    _nutrisiBeratControllers = [];

    final nutrisiList = widget.produk.nutrisi.split(', ');
    for (var n in nutrisiList) {
      final match = RegExp(r'(.+)\s\((.+)\)').firstMatch(n);
      _nutrisiNamaControllers.add(
        TextEditingController(text: match?.group(1) ?? ""),
      );
      _nutrisiBeratControllers.add(
        TextEditingController(text: match?.group(2) ?? ""),
      );
    }

    // Pastikan ada 1 field minimal
    if (_nutrisiNamaControllers.isEmpty) {
      _nutrisiNamaControllers.add(TextEditingController());
      _nutrisiBeratControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
    for (var c in _nutrisiNamaControllers) c.dispose();
    for (var c in _nutrisiBeratControllers) c.dispose();
    super.dispose();
  }

  void _updateProduk() async {
    final updatedNutrisi = <String>[];
    for (int i = 0; i < _nutrisiNamaControllers.length; i++) {
      final nama = _nutrisiNamaControllers[i].text.trim();
      final berat = _nutrisiBeratControllers[i].text.trim();
      if (nama.isNotEmpty && berat.isNotEmpty) {
        updatedNutrisi.add('$nama ($berat)');
      }
    }

    if (_namaController.text.isEmpty || _kodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan kode harus diisi')),
      );
      return;
    }

    final updatedProduk = ProdukModel(
      nama: _namaController.text,
      kode: _kodeController.text,
      nutrisi: updatedNutrisi.join(', '),
      tambahan: widget.produk.tambahan,
      risiko: widget.produk.risiko,
    );

    final box = Hive.box<ProdukModel>('produk');
    await box.putAt(widget.index, updatedProduk);

    Navigator.pop(context);
  }

  void _addNutrisiField() {
    setState(() {
      _nutrisiNamaControllers.add(TextEditingController());
      _nutrisiBeratControllers.add(TextEditingController());
    });
  }

  void _removeNutrisiField(int index) {
    setState(() {
      _nutrisiNamaControllers.removeAt(index);
      _nutrisiBeratControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE85D04),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'EatoScan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 24),
                      _buildInputRow('Nama Produk', _namaController),
                      _buildInputRow('Kode Produk', _kodeController),
                      const SizedBox(height: 16),
                      const Text('Kandungan Nutrisi'),
                      const SizedBox(height: 8),
                      ...List.generate(_nutrisiNamaControllers.length, (index) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _nutrisiNamaControllers[index],
                                decoration: const InputDecoration(
                                  hintText: 'Nama',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _nutrisiBeratControllers[index],
                                decoration: const InputDecoration(
                                  hintText: 'Berat',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                index == _nutrisiNamaControllers.length - 1
                                    ? Icons.add
                                    : Icons.remove,
                              ),
                              onPressed: () {
                                if (index ==
                                    _nutrisiNamaControllers.length - 1) {
                                  _addNutrisiField();
                                } else {
                                  _removeNutrisiField(index);
                                }
                              },
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF225840),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _updateProduk,
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
