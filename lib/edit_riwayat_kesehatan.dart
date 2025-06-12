import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crud_penyakit.dart';

class EditRiwayatKesehatanPage extends StatefulWidget {
  const EditRiwayatKesehatanPage({super.key});

  @override
  State<EditRiwayatKesehatanPage> createState() =>
      _EditRiwayatKesehatanPageState();
}

class _EditRiwayatKesehatanPageState extends State<EditRiwayatKesehatanPage> {
  String? _gender;
  Map<String, bool> _penyakitStatus = {};
  String? _savedGender;
  Map<String, bool> _savedPenyakitStatus = {};
  bool _hasChanges = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inisialisasi status checkbox
    _initializePenyakitStatus();
    // Muat data tersimpan
    _loadSavedData();
  }

  // Inisialisasi status penyakit
  void _initializePenyakitStatus() {
    for (var penyakit in PenyakitFormPage.dataPenyakit) {
      _penyakitStatus[penyakit['nama']] = false;
      _savedPenyakitStatus[penyakit['nama']] = false;
    }
  }

  // Memuat data dari SharedPreferences
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _gender = prefs.getString('gender');
        _savedGender = _gender;
        for (var penyakit in PenyakitFormPage.dataPenyakit) {
          final nama = penyakit['nama'];
          _penyakitStatus[nama] = prefs.getBool('penyakit_$nama') ?? false;
          _savedPenyakitStatus[nama] = _penyakitStatus[nama]!;
        }
        _hasChanges = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Menyimpan data ke SharedPreferences
  Future<void> _simpanData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gender', _gender ?? '');
      for (var penyakit in PenyakitFormPage.dataPenyakit) {
        final nama = penyakit['nama'];
        await prefs.setBool('penyakit_$nama', _penyakitStatus[nama] ?? false);
      }
      setState(() {
        _savedGender = _gender;
        _savedPenyakitStatus = Map.from(_penyakitStatus);
        _hasChanges = false;
      });
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Berhasil"),
              content: const Text("Data riwayat kesehatan telah disimpan."),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mengecek apakah ada perubahan
  void _checkForChanges() {
    bool hasChanges =
        _gender != _savedGender ||
        _penyakitStatus.entries.any(
          (entry) => _savedPenyakitStatus[entry.key] != entry.value,
        );
    setState(() {
      _hasChanges = hasChanges;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2F684A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Riwayat Kesehatan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // dummy space
                ],
              ),
            ),

            // Body putih melengkung
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/eatoscan.png', height: 100),
                      const SizedBox(height: 20),
                      const Text(
                        "Riwayat Kesehatan Pengguna",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Jenis Kelamin
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Jenis Kelamin"),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Laki-laki"),
                              value: "Laki-laki",
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value;
                                  _checkForChanges();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Perempuan"),
                              value: "Perempuan",
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value;
                                  _checkForChanges();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Riwayat Penyakit
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Apakah anda memiliki riwayat dibawah ini?",
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "*pilih satu atau lebih",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      // Daftar penyakit dari CrudPenyakit
                      if (PenyakitFormPage.dataPenyakit.isEmpty)
                        const Text(
                          "Belum ada data penyakit tersedia",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      else
                        ...PenyakitFormPage.dataPenyakit.map((penyakit) {
                          return CheckboxListTile(
                            title: Text(
                              penyakit['nama'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: _penyakitStatus[penyakit['nama']] ?? false,
                            onChanged: (val) {
                              setState(() {
                                _penyakitStatus[penyakit['nama']] = val!;
                                _checkForChanges();
                              });
                            },
                          );
                        }).toList(),
                      const SizedBox(height: 8),
                      const Text(
                        "nb: tidak perlu memilih jika tidak memiliki riwayat penyakit tertentu",
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 30),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _hasChanges ? _simpanData : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE85D04),
                            disabledBackgroundColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Simpan",
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
}
