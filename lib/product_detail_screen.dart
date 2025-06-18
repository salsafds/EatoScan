import 'dart:io';
import 'package:flutter/material.dart';
import 'produk_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProdukModel product;
  final String imagePath;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.imagePath,
  });

  Map<String, String> _parseNutrients(String nutrisiString) {
    final Map<String, String> nutrients = {};
    if (nutrisiString.isNotEmpty) {
      final parts = nutrisiString.split(', ');
      for (var part in parts) {
        final match = RegExp(r'(.+)\s$$(.+)\s?g$$').firstMatch(part);
        if (match != null) {
          nutrients[match.group(1)!] = match.group(2)!;
        }
      }
    }
    return nutrients;
  }

  // Fungsi untuk menentukan warna berdasarkan nilai nutrisi
  Color _getNutrientColor(String nutrient, double value) {
    switch (nutrient.toLowerCase()) {
      case 'gula':
        return value > 10 ? Colors.red : Colors.green;
      case 'garam':
        return value > 1 ? Colors.red : Colors.green;
      case 'lemak':
        return value > 5 ? Colors.red : Colors.green;
      case 'kalori':
        return value > 200 ? Colors.red : Colors.green;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutrients = _parseNutrients(product.nutrisi);
    final isAssetImage = imagePath.startsWith('assets/');

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
                              product.nama,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              product.tambahan,
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
                      
                      // Nutrient cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.5,
                          children: [
                            _buildNutrientCard('Kalori', '150', 'Rendah'),
                            _buildNutrientCard('Lemak', '5', 'Rendah'),
                            _buildNutrientCard('Karbo', '25', 'Rendah'),
                            _buildNutrientCard('Protein', '3', 'Rendah'),
                            _buildNutrientCard('Gula', '20', 'Tinggi', isHigh: true),
                            _buildNutrientCard('Garam', '0.5', 'Rendah'),
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
                          children: [
                            _buildRecommendationCard(
                              'Tropicana Slim 7 Fruit Fiber Daily',
                              'Sugar Free',
                            ),
                            _buildRecommendationCard(
                              'Tropicana Slim Sugar Free California Orange',
                              'Sugar Free',
                            ),
                          ],
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
                              _buildNutritionRow('Takaran kemasan', '${product.takaranKemasan} gram'),
                              _buildNutritionRow('Sajian per kemasan', '${product.sajianPerKemasan}'),
                              const Divider(),
                              ...nutrients.entries.map((entry) {
                                return _buildNutritionRow(entry.key, '${entry.value} g');
                              }).toList(),
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

  Widget _buildNutrientCard(String name, String value, String status, {bool isHigh = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isHigh ? Colors.red : Colors.green,
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
            ),
            textAlign: TextAlign.center,
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