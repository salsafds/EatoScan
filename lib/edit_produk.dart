import 'package:flutter/material.dart';
import 'package:eatoscan/produk_model.dart';
import 'package:eatoscan/lihat_produk.dart';
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
  late List<TextEditingController> _risikoControllers;
  String? _selectedKategori;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.produk.nama);
    _kodeController = TextEditingController(text: widget.produk.kode);

    _nutrisiNamaControllers = [];
    _nutrisiBeratControllers = [];

    final nutrisiList = widget.produk.nutrisi.split(', ');
    for (var n in nutrisiList) {
      final match = RegExp(r'(.+)\s\((.+) g\)').firstMatch(n);
      _nutrisiNamaControllers.add(
        TextEditingController(text: match?.group(1) ?? ""),
      );
      _nutrisiBeratControllers.add(
        TextEditingController(text: match?.group(2) ?? ""),
      );
    }

    _risikoControllers =
        widget.produk.risiko
            .split(', ')
            .map((r) => TextEditingController(text: r))
            .toList();

    _selectedKategori = widget.produk.tambahan;

    if (_nutrisiNamaControllers.isEmpty) {
      _nutrisiNamaControllers.add(TextEditingController());
      _nutrisiBeratControllers.add(TextEditingController());
    }

    if (_risikoControllers.isEmpty) {
      _risikoControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
    for (var c in _nutrisiNamaControllers) c.dispose();
    for (var c in _nutrisiBeratControllers) c.dispose();
    for (var c in _risikoControllers) c.dispose();
    super.dispose();
  }

  void _updateProduk() async {
    final updatedNutrisi = <String>[];
    for (int i = 0; i < _nutrisiNamaControllers.length; i++) {
      final nama = _nutrisiNamaControllers[i].text.trim();
      final berat = _nutrisiBeratControllers[i].text.trim();
      if (nama.isNotEmpty && berat.isNotEmpty) {
        updatedNutrisi.add('$nama ($berat g)');
      }
    }

    final updatedRisiko =
        _risikoControllers
            .map((e) => e.text.trim())
            .where((e) => e.isNotEmpty)
            .toList();

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
      tambahan: _selectedKategori ?? 'Tidak diketahui',
      risiko: updatedRisiko.join(', '),
    );

    final box = Hive.box<ProdukModel>('produk');
    await box.putAt(widget.index, updatedProduk);

    Navigator.pop(context, true);
  }

  void _konfirmasiSimpan() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menyimpan perubahan data produk?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // tutup dialog
                  Navigator.pop(context, true); // kirim sinyal "data berubah"
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _konfirmasiBatal() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Batalkan Perubahan'),
            content: const Text(
              'Yakin ingin membatalkan perubahan dan kembali?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // tutup dialog
                  Navigator.pop(
                    context,
                  ); // kembali ke LihatProdukPage yang asli
                },
                child: const Text('Ya, Batalkan'),
              ),
            ],
          ),
    );
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

  void _addRisikoField() {
    setState(() {
      _risikoControllers.add(TextEditingController());
    });
  }

  void _removeRisikoField(int index) {
    setState(() {
      _risikoControllers.removeAt(index);
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
                          'Ubah Data Produk',
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
                                  hintText: 'Nama Nutrisi',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _nutrisiBeratControllers[index],
                                decoration: const InputDecoration(
                                  hintText: 'Berat (g)',
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
                      const Text('Potensi Risiko'),
                      const SizedBox(height: 8),
                      ...List.generate(_risikoControllers.length, (index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _risikoControllers[index],
                                decoration: const InputDecoration(
                                  hintText: 'Potensi Risiko',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                index == _risikoControllers.length - 1
                                    ? Icons.add
                                    : Icons.remove,
                              ),
                              onPressed: () {
                                if (index == _risikoControllers.length - 1) {
                                  _addRisikoField();
                                } else {
                                  _removeRisikoField(index);
                                }
                              },
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      const Text('Kategori Produk'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedKategori,
                        onChanged:
                            (val) => setState(() => _selectedKategori = val),
                        items: const [
                          DropdownMenuItem(value: 'roti', child: Text('Roti')),
                          DropdownMenuItem(
                            value: 'snack',
                            child: Text('Snack'),
                          ),
                          DropdownMenuItem(
                            value: 'makanan',
                            child: Text('Makanan'),
                          ),
                          DropdownMenuItem(
                            value: 'minuman',
                            child: Text('Minuman'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Pilih Kategori',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _konfirmasiBatal,
                            child: const Text(
                              'Batal',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
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
                            onPressed: _konfirmasiSimpan,
                            child: const Text(
                              'Simpan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
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
