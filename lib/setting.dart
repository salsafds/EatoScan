import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profil.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage>  createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  // Ambil foto profil dari SharedPreferences
  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_picture');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  // Navigasi ke EditProfilPage dan refresh setelah kembali
  Future<void> _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilPage()),
    );
    _loadProfilePicture(); // Refresh foto setelah kembali
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Foto profil
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null
                  ? Icon(Icons.account_circle, size: 60)
                  : null,
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Nama Pengguna',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 32),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Profil'),
            onTap: _navigateToEditProfile,
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Ubah Password'),
            onTap: () {
              // Tambahkan logika jika perlu
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Keluar'),
            onTap: () {
              // Tambahkan logika logout jika perlu
            },
          ),
        ],
      ),
    );
  }
}
