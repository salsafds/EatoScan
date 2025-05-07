import 'package:flutter/material.dart';
import 'package:eatoscan/db_helper.dart'; // Sesuaikan dengan struktur project Anda
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifikasiPasswordController = TextEditingController();

  final DBHelper dbHelper = DBHelper(); // Inisialisasi DBHelper

  void _submitForm() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final verifikasiPassword = _verifikasiPasswordController.text;

    // Validasi manual
    if (username.isEmpty || email.isEmpty || password.isEmpty || verifikasiPassword.isEmpty) {
      _showMessage('Semua kolom harus diisi!');
      return;
    }

    if (password.length < 8) {
      _showMessage('Password harus minimal 8 karakter!');
      return;
    }

    if (password != verifikasiPassword) {
      _showMessage('Password tidak cocok!');
      return;
    }

    if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,4}$").hasMatch(email)) {
      _showMessage('Format email tidak valid!');
      return;
    }

    try {
      await dbHelper.addUser(username: '', email: '', password: '');
      _showMessage('Data berhasil disimpan');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      _showMessage('Gagal menyimpan: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/loginbg.png"),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(30),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 20,
            color: const Color(0xFFEFFBF1), // putihhijaulogin
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF009688), // hijausehat
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(_usernameController, 'Nama Pengguna', Icons.person),
                    const SizedBox(height: 13),
                    _buildTextField(_emailController, 'Email', Icons.email),
                    const SizedBox(height: 13),
                    _buildTextField(_passwordController, 'Kata Sandi', Icons.lock, obscureText: true),
                    const SizedBox(height: 13),
                    _buildTextField(_verifikasiPasswordController, 'Verifikasi Kata Sandi', Icons.lock_outline, obscureText: true),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60),
                        backgroundColor: const Color(0xFF009688),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                      child: const Text('DAFTAR', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Sudah punya akun? Masuk sekarang!',
              style: TextStyle(fontSize: 15, color: Color(0xFF009688)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
