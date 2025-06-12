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
import 'package:eatoscan/lihat_produk.dart'; // Tambahkan impor
import 'package:eatoscan/edit_produk.dart'; // Tambahkan impor
import 'package:eatoscan/signup_screen.dart';
import 'package:eatoscan/login_admin.dart';
import 'package:eatoscan/login_screen.dart';
import 'package:eatoscan/landing_page.dart';
import 'package:eatoscan/crud_produk.dart';
import 'package:eatoscan/crud_penyakit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Web: Tidak pakai path_provider
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProdukModelAdapter());
    await Hive.initFlutter();
    await Hive.openBox('eatoscanBox');
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<ProdukModel>('produk');
    // Hapus 'user' jika tidak digunakan, atau jelaskan penggunaannya
  } else {
    // Mobile (Android/iOS)
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProdukModelAdapter());

    await Hive.openBox('eatoscanBox');
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<ProdukModel>('produk');
    // Hapus 'user' jika tidak digunakan
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
        '/crudPenyakit': (context) => CrudPenyakit(),
        '/dashboard': (context) => const DashboardAdmin(),
        '/lihat_produk':
            (context) => const LihatProdukPage(), // Tambahkan rute ini
        '/edit_produk': (context) {
          // Tangani argumen untuk EditProdukPage
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          if (args == null) {
            throw ArgumentError('Argumen tidak ditemukan untuk /edit_produk');
          }
          final index = args['index'] as int;
          final produk = args['produk'] as ProdukModel;
          return EditProdukPage(index: index, produk: produk);
        },
        // Rute lain bisa ditambahkan di sini jika sudah ada
        // '/scan': (context) => ScanScreen(),
        // '/info': (context) => InformasiScreen(),
        // '/rekom': (context) => RekomendasiScreen(),
      },
      // onGenerateRoute sebagai cadangan (opsional)
      onGenerateRoute: (settings) {
        // Handle rute dinamis jika diperlukan
        return null;
      },
    );
  }
}
