import 'package:flutter/material.dart';

class EditRiwayatKesehatanPage extends StatefulWidget {
  const EditRiwayatKesehatanPage({super.key});

  @override
  State<EditRiwayatKesehatanPage> createState() => _EditRiwayatKesehatanPageState();
}

class _EditRiwayatKesehatanPageState extends State<EditRiwayatKesehatanPage> {
  String? _gender;
  bool _diabetes = false;
  bool _obesitas = false;
  bool _jantung = false;

  void _simpanData() {
    // Logika simpan data bisa ditambahkan di sini
    // Misalnya kirim ke database, API, dll.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Berhasil"),
        content: const Text("Data riwayat kesehatan telah disimpan."),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      Image.asset(
                        'assets/eatoscan_logo.png',
                        height: 100,
                      ),
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
                                setState(() => _gender = value);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Perempuan"),
                              value: "Perempuan",
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() => _gender = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Riwayat Penyakit
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Apakah anda memiliki riwayat dibawah ini?"),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "*pilih satu atau lebih",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text("Diabetes", style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _diabetes,
                        onChanged: (val) => setState(() => _diabetes = val!),
                      ),
                      CheckboxListTile(
                        title: const Text("Obesitas", style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _obesitas,
                        onChanged: (val) => setState(() => _obesitas = val!),
                      ),
                      CheckboxListTile(
                        title: const Text("Jantung", style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _jantung,
                        onChanged: (val) => setState(() => _jantung = val!),
                      ),
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
                          onPressed: _simpanData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE85D04),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Simpan",
                            style: TextStyle(fontSize: 16),
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
