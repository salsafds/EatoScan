import 'package:eatoscan/produk_model.dart';
import 'package:flutter/material.dart';
import 'package:eatoscan/lihat_produk.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class CrudProduk extends StatelessWidget {
  const CrudProduk({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EatoScan',
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Arial'),
      home: const ProductFormPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _takaranKemasanController =
      TextEditingController();
  final TextEditingController _sajianPerKemasanController =
      TextEditingController();
  final List<TextEditingController> _nutrisiNamaControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _nutrisiBeratControllers = [
    TextEditingController(),
  ];
  final List<TextEditingController> _risikoControllers = [
    TextEditingController(),
  ];
  String? _selectedKategori;
  Map<String, bool> _preferensiNutrisi = {
    'bebas_laktosa': false,
    'bebas_gluten': false,
    'vegetarian': false,
    'vegan': false,
  };
  XFile? _gambarProduk;
  String? _gambarPath;

  Future<void> _pilihGambar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _gambarProduk = pickedFile;
      });
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName');
      setState(() {
        _gambarPath = savedImage.path;
      });
    }
  }

  void _resetForm() {
    _namaController.clear();
    _kodeController.clear();
    _takaranKemasanController.clear();
    _sajianPerKemasanController.clear();
    for (var controller in _nutrisiNamaControllers) {
      controller.clear();
    }
    for (var controller in _nutrisiBeratControllers) {
      controller.clear();
    }
    for (var controller in _risikoControllers) {
      controller.clear();
    }
    setState(() {
      _selectedKategori = null;
      _preferensiNutrisi = {
        'bebas_laktosa': false,
        'bebas_gluten': false,
        'vegetarian': false,
        'vegan': false,
      };
      _gambarProduk = null;
      _gambarPath = null;
      _nutrisiNamaControllers.clear();
      _nutrisiBeratControllers.clear();
      _risikoControllers.clear();
      _nutrisiNamaControllers.add(TextEditingController());
      _nutrisiBeratControllers.add(TextEditingController());
      _risikoControllers.add(TextEditingController());
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
    _takaranKemasanController.dispose();
    _sajianPerKemasanController.dispose();
    for (var c in _nutrisiNamaControllers) {
      c.dispose();
    }
    for (var c in _nutrisiBeratControllers) {
      c.dispose();
    }
    for (var c in _risikoControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _simpanProduk() async {
    if (_namaController.text.isEmpty || _kodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal: Nama dan kode produk harus diisi.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final nutrisiList = <String>[];
    for (int i = 0; i < _nutrisiNamaControllers.length; i++) {
      final nama = _nutrisiNamaControllers[i].text.trim();
      final berat = _nutrisiBeratControllers[i].text.trim();
      if (nama.isEmpty || berat.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal: Nama dan berat nutrisi harus diisi.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      nutrisiList.add('$nama ($berat g)');
    }

    if (_takaranKemasanController.text.isEmpty ||
        _sajianPerKemasanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal: Takaran kemasan dan sajian per kemasan harus diisi.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal: Kategori produk harus dipilih.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final risikoList = <String>[];
    for (var controller in _risikoControllers) {
      final text = controller.text.trim();
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal: Semua potensi risiko harus diisi.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      risikoList.add(text);
    }

    try {
      final produk = ProdukModel(
        nama: _namaController.text,
        kode: _kodeController.text,
        nutrisi: nutrisiList.join(', '),
        tambahan: _selectedKategori ?? 'Tidak diketahui',
        risiko: risikoList.join(', '),
        preferensiNutrisi: _preferensiNutrisi,
        takaranKemasan: double.parse(_takaranKemasanController.text),
        sajianPerKemasan: double.parse(_sajianPerKemasanController.text),
        gambarPath: _gambarPath,
      );

      final produkBox = Hive.box<ProdukModel>('produk');
      await produkBox.add(produk);

      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sukses: Produk berhasil disimpan.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: Terjadi kesalahan saat menyimpan produk. ($e)'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _lihatData() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LihatProdukPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE85D04),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        _resetForm();
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed('/dashboard');
                      },
                    ),
                  ),
                  const Center(
                    child: Text(
                      'EatoScan',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                          children: [
                            const Center(
                              child: Text(
                                'Data Produk',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FormFieldWithLabel(
                              label: 'Nama Produk',
                              controller: _namaController,
                            ),
                            FormFieldWithLabel(
                              label: 'Kode Produk',
                              controller: _kodeController,
                            ),
                            FormFieldWithLabel(
                              label: 'Takaran Kemasan (g)',
                              controller: _takaranKemasanController,
                              keyboardType: TextInputType.number,
                            ),
                            FormFieldWithLabel(
                              label: 'Sajian per Kemasan',
                              controller: _sajianPerKemasanController,
                              keyboardType: TextInputType.number,
                            ),
                            NutritionInputList(
                              namaControllers: _nutrisiNamaControllers,
                              beratControllers: _nutrisiBeratControllers,
                            ),
                            RiskInputList(controllerList: _risikoControllers),
                            CategoryDropdown(
                              onChanged:
                                  (value) =>
                                      setState(() => _selectedKategori = value),
                              selectedValue: _selectedKategori,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Preferensi Nutrisi',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Column(
                              children:
                                  _preferensiNutrisi.keys.map((key) {
                                    return CheckboxListTile(
                                      title: Text(
                                        key.replaceAll('_', ' ').toUpperCase(),
                                      ),
                                      value: _preferensiNutrisi[key],
                                      onChanged: (value) {
                                        setState(() {
                                          _preferensiNutrisi[key] =
                                              value ?? false;
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 120,
                                  child: Text('Gambar Produk'),
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _pilihGambar,
                                    child: Text(
                                      _gambarProduk == null
                                          ? 'Pilih Gambar'
                                          : 'Gambar Dipilih',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_gambarProduk != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Image.file(
                                  File(_gambarProduk!.path),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    ActionButtons(onSimpan: _simpanProduk, onLihat: _lihatData),
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
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const FormFieldWithLabel({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(label),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NutritionInputList extends StatefulWidget {
  final List<TextEditingController> namaControllers;
  final List<TextEditingController> beratControllers;

  const NutritionInputList({
    super.key,
    required this.namaControllers,
    required this.beratControllers,
  });

  @override
  State<NutritionInputList> createState() => _NutritionInputListState();
}

class _NutritionInputListState extends State<NutritionInputList> {
  void _addField() {
    setState(() {
      widget.namaControllers.add(TextEditingController());
      widget.beratControllers.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    setState(() {
      widget.namaControllers.removeAt(index);
      widget.beratControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.namaControllers.length, (index) {
        return NutritionInputRow(
          nameController: widget.namaControllers[index],
          amountController: widget.beratControllers[index],
          isLast: index == widget.namaControllers.length - 1,
          onAdd: _addField,
          onRemove: () => _removeField(index),
          showLabel: index == 0,
        );
      }),
    );
  }
}

class RiskInputList extends StatefulWidget {
  final List<TextEditingController> controllerList;

  const RiskInputList({super.key, required this.controllerList});

  @override
  State<RiskInputList> createState() => _RiskInputListState();
}

class _RiskInputListState extends State<RiskInputList> {
  void _addField() {
    setState(() {
      widget.controllerList.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    setState(() {
      widget.controllerList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.controllerList.length, (index) {
        return RiskInputRow(
          controller: widget.controllerList[index],
          isLast: index == widget.controllerList.length - 1,
          onAdd: _addField,
          onRemove: () => _removeField(index),
          showLabel: index == 0,
        );
      }),
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
            child:
                showLabel
                    ? const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('Kandungan\nNutrisi'),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: amountController,
                    style: const TextStyle(fontSize: 12),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Berat (g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
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

class RiskInputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final bool isLast;
  final bool showLabel;

  const RiskInputRow({
    super.key,
    required this.controller,
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
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child:
                  showLabel
                      ? const Text('Potensi Risiko')
                      : const SizedBox.shrink(),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
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

class CategoryDropdown extends StatelessWidget {
  final Function(String?) onChanged;
  final String? selectedValue;

  const CategoryDropdown({
    super.key,
    required this.onChanged,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 120,
          child: Padding(
            padding: EdgeInsets.only(top: 14),
            child: Text('Kategori Produk'),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            onChanged: onChanged,
            items: const [
              DropdownMenuItem(value: 'roti', child: Text('Roti')),
              DropdownMenuItem(value: 'snack', child: Text('Snack')),
              DropdownMenuItem(value: 'makanan', child: Text('Makanan')),
              DropdownMenuItem(value: 'minuman', child: Text('Minuman')),
            ],
            decoration: InputDecoration(
              hintText: 'Kategori Produk',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback onSimpan;
  final VoidCallback onLihat;

  const ActionButtons({
    super.key,
    required this.onSimpan,
    required this.onLihat,
  });

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
              backgroundColor: const Color(0xFF225840),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onLihat,
            child: const Text(
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
              backgroundColor: const Color(0xFF225840),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onSimpan,
            child: const Text(
              'Simpan',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
