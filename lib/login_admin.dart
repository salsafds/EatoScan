import 'package:flutter/material.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Semua kolom harus diisi!');
      return;
    }

    if (password.length < 8) {
      _showMessage('Password harus minimal 8 karakter!');
      return;
    }

    // if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,4}$").hasMatch(email)) {
    //   _showMessage('Format email tidak valid!');
    //   return;
    // }

    // TODO: Add login logic
    // String password = _passwordController.text;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        // backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE65100),
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
            const SizedBox(height: 10),
            Image.asset('assets/images/eatoscan.png', height: 60),
            const SizedBox(height: 12),
            // const SizedBox(height: 10),
            Image.asset('assets/images/eatoscan1.png', height: 18),
            // const Text(
            //   'EAToSCAN',
            //   style: TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //     color: Color(0xFFE65100),
            //   ),
            // ),
            const SizedBox(height: 32),
            _buildTextField(_usernameController, 'Masukkan nama admin', 'Nama'),
            const SizedBox(height: 20),
            _buildTextField(_passwordController, 'Masukkan kata sandi', 'Kata Sandi', obscureText: true),
            const SizedBox(height: 24),
            _buildLoginButton(),
            const SizedBox(height: 12),
            // _buildForgotPasswordButton(),
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
          backgroundColor: const Color.fromARGB(255, 12, 84, 16),
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
  // Widget _buildForgotPasswordButton() {
  //   return TextButton(
  //     onPressed: () {
  //       // TODO: Handle forgotten password
  //     },
  //     child: const Text(
  //       'Lupa kata sandi?',
  //       style: TextStyle(
  //         fontSize: 14,
  //         color: Colors.blueAccent,
  //       ),
  //     ),
  //   );
  // }

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
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Masuk sebagai user.',
              style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 12, 84, 16),fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    ),
  );
} 
}
