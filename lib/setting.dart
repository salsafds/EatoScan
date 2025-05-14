import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profil.dart';
import 'edit_riwayat_kesehatan.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SettingPage(),
  ));
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage>  createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  File? _profileImage;
  String _userName = 'Bromo';
  String _userEmail = 'bromo@gmail.com';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_picture');
    final name = prefs.getString('user_name') ?? 'Bromo';
    final email = prefs.getString('user_email') ?? 'bromo@gmail.com';

    setState(() {
      if (imagePath != null && File(imagePath).existsSync()) {
        _profileImage = File(imagePath);
      }
      _userName = name;
      _userEmail = email;
    });
  }

  Future<void> _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilPage()),
    );
    _loadProfileData(); // refresh data
  }

  void _showLogoutDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apakah Anda yakin ingin keluar dari akun ini?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Ya
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // tutup dialog
                    // Tambahkan logika logout di sini
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text(
                    'Ya',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                // Tombol Tidak
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // tutup dialog
                  },
                  child: Text(
                    'Tidak',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Color(0xFF2D6A4F),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF2D6A4F),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            padding: EdgeInsets.only(top: 16, bottom: 32),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : AssetImage('assets/images/default_profil.jpg') as ImageProvider,
                ),
                SizedBox(height: 12),
                Text(
                  _userName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userEmail,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(Icons.person, 'Edit Profil', _navigateToEditProfile),
                _buildMenuItem(Icons.favorite_border, 'Edit Riwayat Kesehatan', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditRiwayatKesehatanPage()),
                  );
                }),
                _buildMenuItem(Icons.logout, 'Keluar', _showLogoutDialog),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Image.asset(
              'assets/images/eatoscan1.png',
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: onTap,
        ),
        Divider(),
      ],
    );
  }
}
