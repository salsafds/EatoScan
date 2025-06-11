import 'package:flutter/material.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  _EditProfilPageState createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController kataSandiLamaController = TextEditingController();
  final TextEditingController kataSandiBaruController = TextEditingController();
  final TextEditingController konfirmasiSandiController = TextEditingController();

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF265D4F), width: 2),
      ),
    );
  }

  Future<void> _simpanPerubahan() async {
    if (namaController.text.isEmpty ||
        teleponController.text.isEmpty ||
        emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon lengkapi semua data pengguna.')),
      );
      return;
    }

    if (kataSandiBaruController.text != konfirmasiSandiController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konfirmasi kata sandi tidak cocok.')),
      );
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF265D4F),
      appBar: AppBar(
        backgroundColor: Color(0xFF265D4F),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('assets/images/default_profil.jpg'),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Data Pengguna',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: namaController,
                        decoration: inputStyle('Username'),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: teleponController,
                        decoration: inputStyle('Nomor Telepon'),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: inputStyle('Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Ganti Kata Sandi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: kataSandiLamaController,
                        decoration: inputStyle('Kata Sandi Lama'),
                        obscureText: true,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: kataSandiBaruController,
                        decoration: inputStyle('Kata Sandi Baru'),
                        obscureText: true,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: konfirmasiSandiController,
                        decoration: inputStyle('Konfirmasi Kata Sandi Baru'),
                        obscureText: true,
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/lupa-kata-sandi');
                        },
                        child: Text(
                          'Lupa kata sandi?',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(height: 28),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF265D4F),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _simpanPerubahan,
                        child: Center(
                          child: Text(
                            'Simpan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
