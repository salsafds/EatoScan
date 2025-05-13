import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    // TODO: Add login logic
    String username = _emailController.text;
    // String password = _passwordController.text;
    Navigator.pushReplacementNamed(context, '/dashboard', arguments: username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 84, 16),
      body: Column(
        children: [
          const SizedBox(height: 40),
          _buildWelcomeText(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildLoginForm(),
          ),
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }

  // Method to build the welcome text
  Widget _buildWelcomeText() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 24), // Beri jarak 16dp dari sisi kiri
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Selamat Datang di',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 24), // Beri jarak 16dp dari sisi kiri
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'EatoScan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Method to build the form for logging in
  Widget _buildLoginForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Image.asset('assets/images/eatoscan.jpg', height: 80),
            const SizedBox(height: 12),
            const Text(
              'EAToSCAN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(_emailController, 'abcd@gmail.com', 'Email'),
            const SizedBox(height: 20),
            _buildTextField(_passwordController, 'Masukkan kata sandi', 'Kata Sandi', obscureText: true),
            const SizedBox(height: 24),
            _buildLoginButton(),
            const SizedBox(height: 12),
            _buildForgotPasswordButton(),
          ],
        ),
      ),
    );
  }

  // Method to build a single text field
  Widget _buildTextField(TextEditingController controller, String hintText, String labelText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Method to build the login button
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE65100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _handleLogin,
        child: const Text(
          'Masuk',
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }

  // Method to build the 'forgot password' button
  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        // TODO: Handle forgotten password
      },
      child: const Text(
        'Lupa kata sandi?',
        style: TextStyle(
          fontSize: 14,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // Method to build the bottom navigation bar
  Widget _buildBottomNavigationBar(BuildContext context) {
  return Container(
    color: Colors.white, // Ensure this is white
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity, // Makes the button full width
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/signup');
            },
            child: const Text(
              'Belum punya akun? Daftar sekarang!',
              style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 12, 84, 16),fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity, // Makes the button full width
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/loginAdmin');
            },
            child: const Text(
              'Masuk sebagai admin.',
              style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 12, 84, 16),fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );
} 
}