import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profil.dart';
import 'edit_riwayat_kesehatan.dart';

void main() {
  runApp(MaterialApp(
    home: SettingPage(), // ganti dengan nama widget utama yang ada di file ini
  ));
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  File? _profileImage;
  String _userName = 'Guest';
  String _userEmail = 'guest@example.com';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final box = Hive.box('user');
    
    final currentUser = box.get('loggedInUser');
    final name = box.get('user_name_$currentUser');
    final email = box.get('user_email_$currentUser');
    final imagePath = prefs.getString('profile_picture');

      // setState(() {
      //   _userName = name;
      //   _userEmail = email;
      //   _profileImage = imagePath != null ? File(imagePath) : null;
      // });

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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                        final box = Hive.box('eatoscanBox');
                        await box.delete('loggedInUser');
                        await box.put('isLoggedIn', false);
                        Navigator.pushNamedAndRemoveUntil(context, '/landingPage',(Route<dynamic> route) => false,);
                    },
                    child: Text('Ya', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Tidak', style: TextStyle(color: Colors.white)),
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
      backgroundColor: const Color(0xFF2F684A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/landingPage'),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Pengaturan',
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
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage('assets/images/default_profil.jpg')
                                    as ImageProvider,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _userName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _userEmail,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildMenuItem(Icons.person, 'Edit Profil', _navigateToEditProfile),
                          _buildMenuItem(Icons.favorite_border, 'Edit Riwayat Kesehatan', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditRiwayatKesehatanPage()),
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
              ),
            ),
          ],
        ),
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }
}
