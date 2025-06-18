import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'produk_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProdukModel product;
  final String imagePath;
  late final Box<ProdukModel> _produkBox;

  ProductDetailScreen({
    super.key,
    required this.product,
    required this.imagePath,
  }) {
    _produkBox = Hive.box<ProdukModel>('produk');
  }

  // Fungsi parsing yang lebih robust dengan multiple fallback patterns
  Map<String, String> _parseNutrients(String nutrisiString) {
    final Map<String, String> nutrients = {};
    
    // Log untuk debugging
    print('=== PARSING NUTRIENTS ===');
    print('Input: "$nutrisiString"');
    print('Length: ${nutrisiString.length}');
    print('Is empty: ${nutrisiString.isEmpty}');
    
    if (nutrisiString.isEmpty) {
      print('String kosong, return empty map');
      return nutrients;
    }
    
    final parts = nutrisiString.split(', ');
    print('Split parts: $parts');
    print('Number of parts: ${parts.length}');
    
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i].trim();
      print('Processing part $i: "$part"');
      
      if (part.isEmpty) {
        print('Part kosong, skip');
        continue;
      }
      
      bool matched = false;
      
      // Pattern 1: "Nama (Berat g)"
      RegExpMatch? match = RegExp(r'(.+)\s*$$(.+)\s*g$$').firstMatch(part);
      if (match != null) {
        final name = match.group(1)?.trim() ?? '';
        final weight = match.group(2)?.trim() ?? '';
        print('Pattern 1 matched: name="$name", weight="$weight"');
        if (name.isNotEmpty && weight.isNotEmpty) {
          nutrients[name] = weight;
          matched = true;
        }
      }
      
      // Pattern 2: "Nama (Berat)" tanpa g
      if (!matched) {
        match = RegExp(r'(.+)\s*$$(.+)$$').firstMatch(part);
        if (match != null) {
          final name = match.group(1)?.trim() ?? '';
          var weight = match.group(2)?.trim() ?? '';
          weight = weight.replaceAll(RegExp(r'\s*(g|mg|kkal|kcal|ml|l)\s*$', caseSensitive: false), '');
          print('Pattern 2 matched: name="$name", weight="$weight"');
          if (name.isNotEmpty && weight.isNotEmpty) {
            nutrients[name] = weight;
            matched = true;
          }
        }
      }
      
      // Pattern 3: "Nama: Berat g"
      if (!matched) {
        match = RegExp(r'(.+):\s*(.+)').firstMatch(part);
        if (match != null) {
          final name = match.group(1)?.trim() ?? '';
          var weight = match.group(2)?.trim() ?? '';
          weight = weight.replaceAll(RegExp(r'\s*(g|mg|kkal|kcal|ml|l)\s*$', caseSensitive: false), '');
          print('Pattern 3 matched: name="$name", weight="$weight"');
          if (name.isNotEmpty && weight.isNotEmpty) {
            nutrients[name] = weight;
            matched = true;
          }
        }
      }
      
      // Pattern 4: "Nama Berat g" (space separated)
      if (!matched) {
        final spaceParts = part.split(' ');
        if (spaceParts.length >= 2) {
          // Cari angka dari belakang
          for (int j = spaceParts.length - 1; j >= 1; j--) {
            final potentialWeight = spaceParts[j].replaceAll(RegExp(r'[^\d.,]'), '');
            if (potentialWeight.isNotEmpty && double.tryParse(potentialWeight.replaceAll(',', '.')) != null) {
              final name = spaceParts.sublist(0, j).join(' ');
              print('Pattern 4 matched: name="$name", weight="$potentialWeight"');
              if (name.isNotEmpty) {
                nutrients[name] = potentialWeight;
                matched = true;
                break;
              }
            }
          }
        }
      }
      
      if (!matched) {
        print('No pattern matched for: "$part"');
      }
    }
    
    print('Final nutrients: $nutrients');
    print('Nutrients count: ${nutrients.length}');
    print('=== END PARSING ===');
    
    return nutrients;
  }

  // Fungsi untuk mendapatkan unit yang sesuai
  String _getNutrientUnit(String nutrient) {
    final lowerNutrient = nutrient.toLowerCase();
    
    if (lowerNutrient.contains('kalori') || lowerNutrient.contains('energi') || lowerNutrient.contains('energy')) {
      return 'kkal';
    } else if (lowerNutrient.contains('natrium') || lowerNutrient.contains('sodium') || lowerNutrient.contains('garam')) {
      return 'mg';
    } else if (lowerNutrient.contains('vitamin') || lowerNutrient.contains('mineral') || lowerNutrient.contains('kalsium')) {
      return 'mg';
    } else {
      return 'g';
    }
  }

  // Fungsi untuk mendapatkan rekomendasi produk
  List<ProdukModel> _getRecommendedProducts() {
    final currentRisks = product.risiko.split(', ').map((r) => r.trim().toLowerCase()).toSet();
    return _produkBox.values.where((p) {
      final otherRisks = p.risiko.split(', ').map((r) => r.trim().toLowerCase()).toSet();
      return p.nama != product.nama && !currentRisks.any(otherRisks.contains);
    }).toList().take(4).toList();
  }

  // Fungsi untuk menentukan warna
  Color _getNutrientColor(String nutrient, double value) {
    final lowerNutrient = nutrient.toLowerCase();
    
    if (lowerNutrient.contains('gula') || lowerNutrient.contains('sugar')) {
      return value > 10 ? Colors.red : Colors.green;
    } else if (lowerNutrient.contains('garam') || lowerNutrient.contains('sodium') || lowerNutrient.contains('natrium')) {
      return value > 1000 ? Colors.red : Colors.green;
    } else if (lowerNutrient.contains('lemak') || lowerNutrient.contains('fat')) {
      return value > 5 ? Colors.red : Colors.green;
    } else if (lowerNutrient.contains('kalori') || lowerNutrient.contains('energi')) {
      return value > 200 ? Colors.red : Colors.green;
    } else {
      return Colors.green;
    }
  }

  // Fungsi untuk menentukan status
  String _getNutrientStatus(String nutrient, double value) {
    final lowerNutrient = nutrient.toLowerCase();
    
    if (lowerNutrient.contains('gula') || lowerNutrient.contains('sugar')) {
      return value > 10 ? 'Tinggi' : 'Rendah';
    } else if (lowerNutrient.contains('garam') || lowerNutrient.contains('sodium') || lowerNutrient.contains('natrium')) {
      return value > 1000 ? 'Tinggi' : 'Rendah';
    } else if (lowerNutrient.contains('lemak') || lowerNutrient.contains('fat')) {
      return value > 5 ? 'Tinggi' : 'Rendah';
    } else if (lowerNutrient.contains('kalori') || lowerNutrient.contains('energi')) {
      return value > 200 ? 'Tinggi' : 'Rendah';
    } else {
      return 'Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse nutrients di awal dan log hasilnya
    final nutrients = _parseNutrients(product.nutrisi);
    final recommendedProducts = _getRecommendedProducts();
    final isAssetImage = imagePath.startsWith('assets/');
    
    // Log untuk memastikan data ada
    // print('=== BUILD METHOD ===');
    // print('Product nutrisi: "${product.nutrisi}"');
    // print('Parsed nutrients count: ${nutrients.length}');
    // print('Nutrients: $nutrients');
    // print('=== END BUILD LOG ===');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Background image
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: isAssetImage
                    ? AssetImage(imagePath) as ImageProvider
                    : FileImage(File(imagePath)),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          
          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          // Content
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      
                      // Status container - SELALU tampilkan untuk debugging
                      // Container(
                      //   margin: const EdgeInsets.all(16),
                      //   padding: const EdgeInsets.all(8),
                      //   decoration: BoxDecoration(
                      //     color: nutrients.isNotEmpty ? Colors.green[50] : Colors.red[50],
                      //     border: Border.all(
                      //       color: nutrients.isNotEmpty ? Colors.green : Colors.red
                      //     ),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         'Status Parsing: ${nutrients.isNotEmpty ? "SUCCESS ✓" : "FAILED ✗"}',
                      //         style: TextStyle(
                      //           fontWeight: FontWeight.bold,
                      //           color: nutrients.isNotEmpty ? Colors.green[800] : Colors.red[800],
                      //         ),
                      //       ),
                      //       Text('Raw Data: "${product.nutrisi}"'),
                      //       Text('Parsed Count: ${nutrients.length}'),
                      //       if (nutrients.isNotEmpty) ...[
                      //         const Text('Sample Data:'),
                      //         ...nutrients.entries.take(2).map((e) => Text('• ${e.key}: ${e.value}')),
                      //       ],
                      //     ],
                      //   ),
                      // ),
                      
                      // Nutri-Score
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            const Text(
                              'Nutri-Score',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildScoreCircle('A', Colors.green),
                                _buildScoreCircle('B', Colors.lightGreen),
                                _buildScoreCircle('C', Colors.yellow, isSelected: true),
                                _buildScoreCircle('D', Colors.orange),
                                _buildScoreCircle('E', Colors.red),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Product name and category
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              product.nama.isNotEmpty ? product.nama : 'Produk Tidak Ditemukan',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              product.tambahan.isNotEmpty ? product.tambahan : 'Kategori tidak tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Warning section
                      if (product.risiko.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Peringatan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.risiko,
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // Nutrient cards - SELALU tampilkan section ini
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Nutrisi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Tampilkan nutrient cards jika ada data
                            if (nutrients.isNotEmpty) ...[
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.5,
                                children: nutrients.entries.take(6).map((entry) {
                                  final value = double.tryParse(entry.value.replaceAll(',', '.')) ?? 0.0;
                                  final status = _getNutrientStatus(entry.key, value);
                                  final color = _getNutrientColor(entry.key, value);
                                  return _buildNutrientCard(entry.key, entry.value, status, color: color);
                                }).toList(),
                              ),
                            ] else ...[
                              // Tampilkan pesan jika tidak ada data
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.grey[600], size: 48),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Data Nutrisi Tidak Tersedia',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Format data nutrisi tidak dapat diparsing',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Recommendations
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'Rekomendasi Produk Lain',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      SizedBox(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: recommendedProducts.map((recommendedProduct) {
                            return _buildRecommendationCard(
                              recommendedProduct.nama,
                              recommendedProduct.preferensiNutrisi['bebas_laktosa'] == true 
                                ? 'Bebas Laktosa' 
                                : recommendedProduct.preferensiNutrisi['bebas_gluten'] == true
                                  ? 'Bebas Gluten'
                                  : 'Sehat',
                            );
                          }).toList(),
                        ),
                      ),
                      
                      // Nutrition preferences
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'Preferensi Nutrisi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildPreferenceItem(
                              'Bebas Laktosa',
                              product.preferensiNutrisi['bebas_laktosa'] ?? false,
                            ),
                            _buildPreferenceItem(
                              'Bebas Gluten',
                              product.preferensiNutrisi['bebas_gluten'] ?? false,
                            ),
                            _buildPreferenceItem(
                              'Vegetarian',
                              product.preferensiNutrisi['vegetarian'] ?? false,
                            ),
                            _buildPreferenceItem(
                              'Vegan',
                              product.preferensiNutrisi['vegan'] ?? false,
                            ),
                          ],
                        ),
                      ),
                      
                      // Detailed nutrition info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Gizi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Informasi Kemasan
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Informasi Kemasan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _buildNutritionRow('Takaran kemasan', '${product.takaranKemasan.toInt()} gram'),
                                    _buildNutritionRow('Sajian per kemasan', '${product.sajianPerKemasan.toInt()}'),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Kandungan Nutrisi per Sajian
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kandungan Nutrisi per Sajian',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // SELALU tampilkan section ini
                                    if (nutrients.isNotEmpty) ...[
                                      ...nutrients.entries.map((entry) {
                                        final value = double.tryParse(entry.value.replaceAll(',', '.')) ?? 0.0;
                                        final color = _getNutrientColor(entry.key, value);
                                        final unit = _getNutrientUnit(entry.key);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  entry.key,
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: color, width: 0.5),
                                                ),
                                                child: Text(
                                                  '${entry.value} $unit',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: color,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ] else ...[
                                      Text(
                                        'Data nutrisi tidak dapat diparsing dari: "${product.nutrisi}"',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.orange[600],
                                        ),
                                      ),
                                    ],
                                  ],
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle(String letter, Color color, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: color == Colors.yellow ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientCard(String name, String value, String status, {Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String name, String tag) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Icon(Icons.favorite_border, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(String label, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.circle_outlined,
            color: isChecked ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}