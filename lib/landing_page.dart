import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'produk_model.dart';
import 'package:eatoscan/product_detail_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late Box<ProdukModel> _produkBox;
  late Box _userBox;
  bool isScanning = false;
  late bool isLoggedIn;
  late String username;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _produkBox = Hive.box<ProdukModel>('produk');
    _userBox = Hive.box('eatoscanBox');
  }

  Widget _buildHeader(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _userBox.listenable(),
      builder: (context, box, _) {
        final isLoggedIn = box.get('isLoggedIn', defaultValue: false);
        final username = box.get('loggedInUser', defaultValue: 'User');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EatoScan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selamat datang, ${isLoggedIn ? username : 'User'}!',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              isLoggedIn
                  ? IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed:
                        () =>
                            Navigator.pushReplacementNamed(context, '/setting'),
                  )
                  : Container(
                    width: 95,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed:
                          () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScannerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _buildCameraScanner(),
    );
  }

  Widget _buildCameraScanner() {
    return SizedBox(
      width: 300,
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: MobileScanner(
          controller: MobileScannerController(
            detectionSpeed:
                DetectionSpeed.noDuplicates, // Otomatis deteksi tanpa duplikat
            facing: CameraFacing.back,
            torchEnabled: false,
            autoStart: true, // Mulai otomatis
          ),
          onDetect: (BarcodeCapture capture) async {
            if (!isScanning) {
              setState(() => isScanning = true);
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  debugPrint('Barcode ditemukan: $code');
                  final XFile? photo = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (photo != null) {
                    final matchedProduct = _produkBox.values.firstWhere(
                      (produk) => produk.kode == code,
                      orElse:
                          () => ProdukModel(
                            nama: 'Tidak ditemukan',
                            kode: '',
                            nutrisi: '',
                            tambahan: '',
                            risiko: '',
                          ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProductDetailScreen(
                              product: matchedProduct,
                              imagePath: photo.path,
                            ),
                      ),
                    );
                  }
                }
              }
              setState(() => isScanning = false);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProdukList(List<ProdukModel> produkList) {
    if (produkList.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            "Belum ada produk tersedia.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: produkList.length,
        itemBuilder: (context, index) {
          final produk = produkList[index];
          final Color warnaTag = const Color.fromARGB(255, 37, 189, 54);
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/eatoscan.png",
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk.tambahan,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(137, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: warnaTag,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        produk.nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: warnaTag.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: warnaTag,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              produk.risiko.isNotEmpty
                                  ? produk.risiko
                                  : "Tidak diketahui",
                              style: TextStyle(
                                fontSize: 11,
                                color: warnaTag,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ProdukModel> produkList = _produkBox.values.toList();
    return Scaffold(
      backgroundColor: const Color(0xFF1E4D2B),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildScannerSection(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rekomendasi Produk!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildProdukList(produkList),
          ],
        ),
      ),
    );
  }
}
