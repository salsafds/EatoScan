import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  // Simulasi data dari database
  final List<Map<String, dynamic>> produkList = [
    {
      "kategori": "Minuman",
      "nama": "Tropicana Slim 7 Fruit Fiber Daily",
      "tag": "Bebas Gula",
      "warnaTag": const Color.fromARGB(255, 37, 189, 54),
      "gambar": "assets/images/eatoscan.jpg",
    },
    {
      "kategori": "Minuman",
      "nama": "Tropicana Slim Sugar Free California Orange",
      "tag": "Bebas Gula",
      "warnaTag": const Color.fromARGB(255, 37, 189, 54),
      "gambar": "assets/images/eatoscan.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E4D2B),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'EatoScan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Selamat Datang,',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        ' User!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.settings, color: Colors.white),
                ],
              ),
            ),

            // Kamera Placeholder
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 3),
                image: const DecorationImage(
                  image: AssetImage("assets/images/barcode_example.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Rekomendasi Produk
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rekomendasi Produk !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // List Produk
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: produkList.length,
                itemBuilder: (context, index) {
                  final produk = produkList[index]; // ← pastikan ini ada!

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Image.asset(produk["gambar"], width: 60, height: 60),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kategori + Bar hijau
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produk["kategori"],
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
                                      color: produk["warnaTag"],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                produk["nama"],
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
                                  color: produk["warnaTag"].withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  produk["tag"],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: produk["warnaTag"],
                                    fontWeight: FontWeight.w600,
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
