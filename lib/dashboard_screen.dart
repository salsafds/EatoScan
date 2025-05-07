import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String username;

  const DashboardScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Ganti sesuai warna putihnetral
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'EatoScan',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50), // warna hijausehat
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Selamat Datang, $username!',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildCard(
                    context,
                    title: 'Scan Barcode',
                    icon: Icons.qr_code_scanner,
                    color: const Color(0xFFFFEB3B), // kuningsegar
                    onTap: () => Navigator.pushNamed(context, '/scan'),
                  ),
                  _buildCard(
                    context,
                    title: 'Informasi Gizi',
                    icon: Icons.announcement,
                    color: const Color(0xFFFF9800), // oranyeenergi
                    onTap: () => Navigator.pushNamed(context, '/info'),
                  ),
                  _buildCard(
                    context,
                    title: 'Rekomendasi Sehat',
                    icon: Icons.food_bank,
                    color: const Color(0xFF4CAF50), // hijausehat
                    onTap: () => Navigator.pushNamed(context, '/rekom'),
                  ),
                  _buildCard(
                    context,
                    title: 'Profil Pengguna',
                    icon: Icons.account_circle,
                    color: const Color(0xFF616161), // abugelap
                    onTap: () => Navigator.pushNamed(context, '/profil'),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                minimumSize: const Size(140, 48),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Keluar', style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        color: color,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 80, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
