import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; 
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:eatoscan/dashboard_admin.dart';
import 'package:eatoscan/produk_model.dart';
import 'package:eatoscan/setting.dart';
import 'package:eatoscan/splash.dart';
import 'package:eatoscan/user_model.dart';
import 'package:hive_flutter/adapters.dart';

import 'signup_screen.dart';
import 'login_admin.dart';
import 'login_screen.dart';
import 'landing_page.dart';
import 'crud_produk.dart';
import 'crud_penyakit.dart';
// import halaman lain jika sudah ada: scan_screen.dart, informasi_screen.dart, rekomendasi_screen.dart, profil_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Web: Tidak pakai path_provider
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProdukModelAdapter());

    await Hive.openBox('eatoscanBox');
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<ProdukModel>('produk');
    await Hive.openBox('user');
  } else {
    // Mobile (Android/iOS)
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProdukModelAdapter());

    await Hive.openBox('eatoscanBox');
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<ProdukModel>('produk');
    await Hive.openBox('user');
  }
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/loginAdmin': (context) => const LoginAdmin(),
        '/signup': (context) => const SignupScreen(),
        '/landingPage': (context) => LandingPage(),
        '/crudAdmin': (context) => const CrudProduk(),
        '/setting': (context) => SettingPage(),
        '/dashboard': (context) => DashboardAdmin(),
        '/crudPenyakit': (context) => CrudPenyakitPage(),
        // '/scan': (context) => ScanScreen(),
        // '/info': (context) => InformasiScreen(),
        // '/rekom': (context) => RekomendasiScreen(),
        
      },
      // Gunakan onGenerateRoute untuk meng-handle route yang butuh arguments
      onGenerateRoute: (settings) => null,
    );
  }
}
