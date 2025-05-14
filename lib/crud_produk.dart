import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EatoScan',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Arial',
      ),
      home: const ProductFormPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductFormPage extends StatelessWidget {
  const ProductFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE85D04),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: const Center(
                child: Text(
                  'EatoScan',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Content Box
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Center(
                              child: Text(
                                'Data Produk',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            FormFieldWithLabel(label: 'Nama Produk'),
                            FormFieldWithLabel(label: 'Kode Produk'),
                            NutritionInputList(), 
                            RiskInputList(),
                            CategoryDropdown(),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ActionButtons(), // Tombol tetap di bawah
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormFieldWithLabel extends StatelessWidget {
  final String label;

  const FormFieldWithLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                label,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              style: TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class NutritionInputRow extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final bool isLast;
  final bool showLabel;

  const NutritionInputRow({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.onAdd,
    this.onRemove,
    required this.isLast,
    required this.showLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: showLabel
                ? const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Kandungan\nNutrisi',
                      style: TextStyle(fontSize: 14),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Nama Nutrisi',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: amountController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Berat',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(isLast ? Icons.add : Icons.remove),
                  onPressed: isLast ? onAdd : onRemove,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class NutritionInputList extends StatefulWidget {
  const NutritionInputList({super.key});

  @override
  State<NutritionInputList> createState() => _NutritionInputListState();
}

class _NutritionInputListState extends State<NutritionInputList> {
  final List<TextEditingController> _nameControllers = [TextEditingController()];
  final List<TextEditingController> _amountControllers = [TextEditingController()];

  void _addField() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    if (_nameControllers.length > 1) {
      setState(() {
        _nameControllers.removeAt(index);
        _amountControllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    for (var c in _nameControllers) {
      c.dispose();
    }
    for (var c in _amountControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_nameControllers.length, (index) {
        return NutritionInputRow(
          nameController: _nameControllers[index],
          amountController: _amountControllers[index],
          isLast: index == _nameControllers.length - 1,
          onAdd: _addField,
          onRemove: () => _removeField(index),
          showLabel: index == 0,
        );
      }),
    );
  }
}


class RiskInputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final bool isLast;
  final bool showLabel; // Tambahkan flag untuk menampilkan label

  const RiskInputRow({
    super.key,
    required this.controller,
    required this.onAdd,
    this.onRemove,
    required this.isLast,
    required this.showLabel, // Tambahkan ke konstruktor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: showLabel
                  ? const Text(
                      'Potensi Risiko',
                      style: TextStyle(fontSize: 15),
                    )
                  : const SizedBox.shrink(), // sembunyikan label
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Potensi Risiko',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(isLast ? Icons.add : Icons.remove),
                  onPressed: isLast ? onAdd : onRemove,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class RiskInputList extends StatefulWidget {
  const RiskInputList({super.key});

  @override
  State<RiskInputList> createState() => _RiskInputListState();
}

class _RiskInputListState extends State<RiskInputList> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  void _addField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    setState(() {
      _controllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Column(
    children: List.generate(_controllers.length, (index) {
      return RiskInputRow(
        controller: _controllers[index],
        isLast: index == _controllers.length - 1,
        onAdd: _addField,
        onRemove: () => _removeField(index),
        showLabel: index == 0, // hanya baris pertama
      );
    }),
  );
}
}


class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 120,
          child: Padding(
            padding: EdgeInsets.only(top: 14),
            child: Text(
              'Kategori Produk',
              style: TextStyle(fontSize: 15),
              ),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            style: TextStyle(fontSize: 12), // Selected item font
            decoration: InputDecoration(
              hintText: 'Kategori Produk',
              hintStyle: TextStyle(fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            items: const [
              DropdownMenuItem(value: 'roti', child: Text('Roti')),
              DropdownMenuItem(value: 'snack', child: Text('Snack')),
              DropdownMenuItem(value: 'makanan', child: Text('Makanan')),
              DropdownMenuItem(value: 'minuman', child: Text('Minuman')),
            ],
            onChanged: (value) {},
            hint: const Text('Kategori Produk'),
          ),
        ),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 173,
          height: 43,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF225840),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // TODO: Aksi untuk tombol Lihat Data
            },
            child: Text(
              'Lihat Data',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: 13),
        SizedBox(
          width: 173,
          height: 43,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF225840),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // TODO: Aksi untuk tombol Simpan
            },
            child: Text(
              'Simpan',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

