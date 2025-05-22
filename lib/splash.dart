import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'landing_page.dart'; // Ganti dengan halaman tujuanmu

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
void initState() {
  super.initState();
  Future.delayed(const Duration(seconds: 3), () async {
    if (!mounted) return;

    // final box = Hive.box('eatoscanBox');
    // final isLoggedIn = box.get('isLoggedIn', defaultValue: false);

    // if (isLoggedIn) {
    //   Navigator.pushReplacementNamed(context, '/landingPage');
    // } else {
    //   Navigator.pushReplacementNamed(context, '/login');
    // }
    Navigator.pushReplacementNamed(context, '/landingPage');
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center( // Ini membuat logo di tengah layar (secara vertikal & horizontal)
          child: _buildSplashLogo(context),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSplashLogo(BuildContext context) {
    return Image.asset('assets/images/eatoscan.png', height: 150);
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16), // Jarak dari bawah layar
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/eatoscan1.png', height: 25),
        ],
      ),
    );
  }
}
