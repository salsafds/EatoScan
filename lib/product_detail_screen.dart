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
        final match = RegExp(r'(.+)\s\((.+)\s?g\)').firstMatch(part);
        if (match != null) {
          nutrients[match.group(1)!] = match.group(2)!;
        }
      }
    }
    return nutrients;
  }

  @override
  Widget build(BuildContext context) {
    final nutrients = _parseNutrients(product.nutrisi);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eatoscan'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Latar belakang foto yang di-capture
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(imagePath)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const Center(
                      child: Icon(
                        Icons.drag_handle,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product.nama,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      product.tambahan,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.yellow[700],
                      child: Text(
                        product.risiko.isNotEmpty
                            ? 'Peringatan\n${product.risiko}'
                            : 'Tidak ada peringatan',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          nutrients.entries.map((entry) {
                            final isHigh = entry.value.contains(
                              'Tinggi',
                            ); // Placeholder, sesuaikan logika
                            return _NutrientCard(
                              label: entry.key,
                              value: isHigh ? 'Tinggi' : 'Rendah',
                              isHigh: isHigh,
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Rekomendasi Produk Lain',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Placeholder untuk rekomendasi (bisa diisi dari Hive)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ProductCard(
                          name: 'Tropicana Slim 7 Fruit Fiber Daily',
                          isSugarFree: true,
                        ),
                        _ProductCard(
                          name: 'Tropicana Slim Sugar Free California Orange',
                          isSugarFree: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Preferensi Nutrisi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _PreferenceCard(
                          label: 'Bebas Laktosa',
                          isChecked: true,
                        ),
                        _PreferenceCard(label: 'Bebas Gluten', isChecked: true),
                        _PreferenceCard(label: 'Vegetarian', isChecked: true),
                        _PreferenceCard(label: 'Vegan', isChecked: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.yellow[700],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            nutrients.entries.map((entry) {
                              return _NutritionInfo(
                                label: entry.key,
                                value: '${entry.value} g',
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isHigh;

  const _NutrientCard({
    required this.label,
    required this.value,
    this.isHigh = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isHigh ? Colors.red : Colors.green,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final bool isSugarFree;

  const _ProductCard({required this.name, required this.isSugarFree});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const SizedBox(
            height: 50,
            child: Placeholder(),
          ), // Placeholder untuk gambar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(name, textAlign: TextAlign.center),
          ),
          if (isSugarFree) const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  final String label;
  final bool isChecked;

  const _PreferenceCard({required this.label, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle : Icons.circle,
          color: isChecked ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}

class _NutritionInfo extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    );
  }
}
