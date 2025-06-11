import 'package:flutter/material.dart';

class CrudPenyakitPage extends StatefulWidget {
  const CrudPenyakitPage({Key? key}) : super(key: key);

  @override
  State<CrudPenyakitPage> createState() => _CrudPenyakitPageState();
}

class _CrudPenyakitPageState extends State<CrudPenyakitPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _bahanController = TextEditingController();
  
  List<String> _hindariBahan = [];
  List<Map<String, dynamic>> _dataPenyakit = [];
  
  int? _selectedIndex;

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
    setState(() {
      _selectedIndex = null;
      _namaController.clear();
      _deskripsiController.clear();
      _hindariBahan.clear();
    });
  }

  void _simpan() {
    if (_namaController.text.isNotEmpty && _deskripsiController.text.isNotEmpty) {
      setState(() {
        if (_selectedIndex != null) {
          // Update existing data
          _dataPenyakit[_selectedIndex!] = {
            'nama': _namaController.text,
            'deskripsi': _deskripsiController.text,
            'hindariBahan': List.from(_hindariBahan)
          };
        } else {
          // Add new data
          _dataPenyakit.add({
            'nama': _namaController.text,
            'deskripsi': _deskripsiController.text,
            'hindariBahan': List.from(_hindariBahan)
          });
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disimpan')),
      );
      _baru(); // Reset form after save
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama penyakit dan deskripsi harus diisi')),
      );
    }
  }

  void _ubah() {
    if (_selectedIndex != null) {
      setState(() {
        final data = _dataPenyakit[_selectedIndex!];
        _namaController.text = data['nama'];
        _deskripsiController.text = data['deskripsi'];
        _hindariBahan = List.from(data['hindariBahan']);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih data yang akan diubah')),
      );
    }
  }

  void _hapus() {
    if (_selectedIndex != null) {
      setState(() {
        _dataPenyakit.removeAt(_selectedIndex!);
        _selectedIndex = null;
        _baru();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih data yang akan dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'EatoScan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Form Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Penyakit',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nama Penyakit
                  const Text(
                    'Nama Penyakit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        hintText: 'Masukkan nama penyakit...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Deskripsi Penyakit
                  const Text(
                    'Deskripsi Penyakit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _deskripsiController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        hintText: 'Masukkan deskripsi penyakit...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Hindari Bahan
                  const Text(
                    'Hindari Bahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // List of ingredients to avoid
                  ..._hindariBahan.asMap().entries.map((entry) {
                    int index = entry.key;
                    String bahan = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(bahan),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _hapusBahan(index),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  // Add new ingredient
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _bahanController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                              hintText: 'Tambah bahan...',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _tambahBahan,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton('BARU', Colors.teal, _baru),
                      _buildActionButton('SIMPAN', Colors.teal, _simpan),
                      _buildActionButton('UBAH', Colors.teal, _ubah),
                      _buildActionButton('HAPUS', Colors.teal, _hapus),
                    ],
                  ),
                ],
              ),
            ),
            
            // Data Table Section
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              height: 400, // Fixed height untuk tabel
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Nama Penyakit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Deskripsi Penyakit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Hindari Bahan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Table Data
                  Expanded(
                    child: _dataPenyakit.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada data penyakit.\nTambahkan data baru dengan mengisi form di atas.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _dataPenyakit.length,
                            itemBuilder: (context, index) {
                              final data = _dataPenyakit[index];
                              final isSelected = _selectedIndex == index;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.teal.withOpacity(0.1) : null,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected 
                                        ? Border.all(color: Colors.teal, width: 2)
                                        : Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          data['nama'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          data['deskripsi'],
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          (data['hindariBahan'] as List).join(', '),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
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