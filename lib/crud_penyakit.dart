import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CrudPenyakit extends StatelessWidget {
  const CrudPenyakit({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EatoScan',
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Arial'),
      home: const PenyakitFormPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PenyakitFormPage extends StatefulWidget {
  const PenyakitFormPage({super.key});

  static List<Map<String, dynamic>> dataPenyakit = [];

  @override
  State<PenyakitFormPage> createState() => _PenyakitFormPageState();
}

class _PenyakitFormPageState extends State<PenyakitFormPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _bahanController = TextEditingController();

  List<String> _hindariBahan = [];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadPenyakitData();
  }

  // Memuat data penyakit dari SharedPreferences
  Future<void> _loadPenyakitData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? penyakitData = prefs.getString('dataPenyakit');
      if (penyakitData != null) {
        final List<dynamic> decoded = jsonDecode(penyakitData);
        setState(() {
          PenyakitFormPage.dataPenyakit = decoded.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data penyakit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Menyimpan data penyakit ke SharedPreferences
  Future<void> _savePenyakitData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(PenyakitFormPage.dataPenyakit);
      await prefs.setString('dataPenyakit', encoded);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data penyakit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk reset semua input form
  void _resetForm() {
    setState(() {
      _selectedIndex = null;
      _namaController.clear();
      _deskripsiController.clear();
      _bahanController.clear();
      _hindariBahan.clear();
    });
  }

  void _tambahBahan() {
    if (_bahanController.text.isNotEmpty) {
      setState(() {
        _hindariBahan.add(_bahanController.text);
        _bahanController.clear();
      });
    }
  }

  void _hapusBahan(int index) {
    setState(() {
      _hindariBahan.removeAt(index);
    });
  }

  void _baru() {
    _resetForm();
  }

  void _simpan() {
    if (_namaController.text.isEmpty || _deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal: Nama dan deskripsi penyakit harus diisi.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_hindariBahan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal: Minimal satu bahan yang harus dihindari.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      if (_selectedIndex != null) {
        PenyakitFormPage.dataPenyakit[_selectedIndex!] = {
          'nama': _namaController.text,
          'deskripsi': _deskripsiController.text,
          'hindariBahan': List.from(_hindariBahan),
        };
      } else {
        PenyakitFormPage.dataPenyakit.add({
          'nama': _namaController.text,
          'deskripsi': _deskripsiController.text,
          'hindariBahan': List.from(_hindariBahan),
        });
      }
    });

    _savePenyakitData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sukses: Penyakit berhasil disimpan.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _ubah() {
    if (_selectedIndex != null) {
      setState(() {
        final data = PenyakitFormPage.dataPenyakit[_selectedIndex!];
        _namaController.text = data['nama'];
        _deskripsiController.text = data['deskripsi'];
        _hindariBahan = List.from(data['hindariBahan']);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal: Pilih data yang akan diubah.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _hapus() {
    if (_selectedIndex != null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi Hapus'),
              content: Text(
                'Apakah Anda yakin ingin menghapus data penyakit "${PenyakitFormPage.dataPenyakit[_selectedIndex!]['nama']}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Batal
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      PenyakitFormPage.dataPenyakit.removeAt(_selectedIndex!);
                      _selectedIndex = null;
                      _resetForm();
                    });
                    _savePenyakitData();
                    Navigator.of(context).pop(); // Tutup dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sukses: Data berhasil dihapus.'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  child: const Text(
                    'Ya, Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal: Pilih data yang akan dihapus.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE85D04),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        print("Back button ditekan");
                        _resetForm();
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed('/dashboard');
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Data Penyakit',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Nama Penyakit
                            FormFieldWithLabel(
                              label: 'Nama Penyakit',
                              controller: _namaController,
                            ),

                            // Deskripsi Penyakit
                            FormFieldWithLabel(
                              label: 'Deskripsi Penyakit',
                              controller: _deskripsiController,
                              maxLines: 4,
                            ),

                            // Hindari Bahan Section
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 120,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Text('Hindari Bahan'),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      // List of ingredients to avoid
                                      ..._hindariBahan.asMap().entries.map((
                                        entry,
                                      ) {
                                        int index = entry.key;
                                        String bahan = entry.value;
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 14,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    bahan,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(Icons.remove),
                                                onPressed:
                                                    () => _hapusBahan(index),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),

                                      // Add new ingredient
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _bahanController,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Tambah bahan...',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 14,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: _tambahBahan,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  'BARU',
                                  const Color(0xFF225840),
                                  _baru,
                                ),
                                _buildActionButton(
                                  'SIMPAN',
                                  const Color(0xFF225840),
                                  _simpan,
                                ),
                                _buildActionButton(
                                  'UBAH',
                                  const Color(0xFF225840),
                                  _ubah,
                                ),
                                _buildActionButton(
                                  'HAPUS',
                                  const Color(0xFF225840),
                                  _hapus,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Data Table Section
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  // Table Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Nama Penyakit',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Deskripsi',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Hindari Bahan',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Table Data
                                  Expanded(
                                    child:
                                        PenyakitFormPage.dataPenyakit.isEmpty
                                            ? const Center(
                                              child: Text(
                                                'Belum ada data penyakit',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                            : ListView.builder(
                                              itemCount:
                                                  PenyakitFormPage
                                                      .dataPenyakit
                                                      .length,
                                              itemBuilder: (context, index) {
                                                final data =
                                                    PenyakitFormPage
                                                        .dataPenyakit[index];
                                                final isSelected =
                                                    _selectedIndex == index;

                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedIndex = index;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          isSelected
                                                              ? const Color(
                                                                0xFF225840,
                                                              ).withOpacity(0.1)
                                                              : null,
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color:
                                                              Colors.grey[300]!,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            data['nama'],
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  isSelected
                                                                      ? FontWeight
                                                                          .bold
                                                                      : FontWeight
                                                                          .normal,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            data['deskripsi'],
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  isSelected
                                                                      ? FontWeight
                                                                          .bold
                                                                      : FontWeight
                                                                          .normal,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            (data['hindariBahan']
                                                                    as List)
                                                                .join(', '),
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  isSelected
                                                                      ? FontWeight
                                                                          .bold
                                                                      : FontWeight
                                                                          .normal,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 80,
      height: 43,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _bahanController.dispose();
    super.dispose();
  }
}

class FormFieldWithLabel extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const FormFieldWithLabel({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(label),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
