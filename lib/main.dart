import 'package:eatoscan/produk_model.dart';
import 'package:eatoscan/user_model.dart';
import 'package:hive_flutter/adapters.dart';

import 'signup_screen.dart';
import 'login_admin.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
// import halaman lain jika sudah ada: scan_screen.dart, informasi_screen.dart, rekomendasi_screen.dart, profil_screen.dart
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ProdukModelAdapter());
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<ProdukModel>('produk');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EatoScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/loginAdmin': (context) => const LoginAdmin(),
        '/signup': (context) => const SignupScreen(),
        // 
        // '/scan': (context) => ScanScreen(),
        // '/info': (context) => InformasiScreen(),
        // '/rekom': (context) => RekomendasiScreen(),
        // '/profil': (context) => ProfilScreen(),
      },
      // Gunakan onGenerateRoute untuk meng-handle route yang butuh arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final username = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => DashboardScreen(username: username),
          );
        }
        return null;
      },
    );
  }
}
