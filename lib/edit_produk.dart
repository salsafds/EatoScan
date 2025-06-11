import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:eatoscan/produk_model.dart';

class EditProdukPage extends StatefulWidget {
  final int index;
  final ProdukModel produk;

  const EditProdukPage({super.key, required this.index, required this.produk});

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  late TextEditingController _namaController;
  late TextEditingController _kodeController;
  late List<TextEditingController> _nutrisiNamaControllers;
  late List<TextEditingController> _nutrisiBeratControllers;
  late List<TextEditingController> _risikoControllers;
  String? _selectedKategori;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.produk.nama);
    _kodeController = TextEditingController(text: widget.produk.kode);

    _nutrisiNamaControllers = [];
    _nutrisiBeratControllers = [];

    final nutrisiList = widget.produk.nutrisi.split(', ');
    for (var n in nutrisiList) {
      final match = RegExp(r'(.+)\s\((.+) g\)').firstMatch(n);
      _nutrisiNamaControllers.add(
        TextEditingController(text: match?.group(1) ?? ""),
      );
      _nutrisiBeratControllers.add(
        TextEditingController(text: match?.group(2) ?? ""),
      );
    }

    _risikoControllers =
        widget.produk.risiko
            .split(', ')
            .map((r) => TextEditingController(text: r))
            .toList();

    _selectedKategori = widget.produk.tambahan;

    if (_nutrisiNamaControllers.isEmpty) {
      _nutrisiNamaControllers.add(TextEditingController());
      _nutrisiBeratControllers.add(TextEditingController());
    }

    if (_risikoControllers.isEmpty) {
      _risikoControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
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

  void _updateProduk() async {
    final updatedNutrisi = <String>[];
    for (int i = 0; i < _nutrisiNamaControllers.length; i++) {
      final nama = _nutrisiNamaControllers[i].text.trim();
      final berat = _nutrisiBeratControllers[i].text.trim();
      if (nama.isNotEmpty && berat.isNotEmpty) {
        updatedNutrisi.add('$nama ($berat g)');
      }
    }

    final updatedRisiko =
        _risikoControllers
            .map((e) => e.text.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    if (_namaController.text.isEmpty || _kodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan kode harus diisi')),
      );
      return;
    }

    final updatedProduk = ProdukModel(
      nama: _namaController.text,
      kode: _kodeController.text,
      nutrisi: updatedNutrisi.join(', '),
      tambahan: _selectedKategori ?? 'Tidak diketahui',
      risiko: updatedRisiko.join(', '),
    );

    final box = Hive.box<ProdukModel>('produk');
    await box.putAt(widget.index, updatedProduk);

    Navigator.pop(context, true);
  }

  void _konfirmasiSimpan() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menyimpan perubahan data produk?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateProduk();
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _konfirmasiBatal() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Batalkan Perubahan'),
            content: const Text(
              'Yakin ingin membatalkan perubahan dan kembali?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Ya, Batalkan'),
              ),
            ],
          ),
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
                      onPressed: _konfirmasiBatal,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                                'Ubah Data Produk',
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
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    ActionButtons(
                      onSimpan: _konfirmasiSimpan,
                      onLihat: _konfirmasiBatal,
                      simpanLabel: 'Simpan',
                      lihatLabel: 'Batal',
                      simpanColor: const Color(0xFF225840),
                      lihatColor: Colors.grey.shade600,
                    ),
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

// Reusable widgets from CrudProduk
class FormFieldWithLabel extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const FormFieldWithLabel({
    super.key,
    required this.label,
    required this.controller,
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
                    decoration: InputDecoration(
                      hintText: 'Berat',
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
  final String simpanLabel;
  final String lihatLabel;
  final Color simpanColor;
  final Color lihatColor;

  const ActionButtons({
    super.key,
    required this.onSimpan,
    required this.onLihat,
    this.simpanLabel = 'Simpan',
    this.lihatLabel = 'Lihat Data',
    this.simpanColor = const Color(0xFF225840),
    this.lihatColor = const Color(0xFF225840),
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
              backgroundColor: lihatColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onLihat,
            child: Text(
              lihatLabel,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 13),
        SizedBox(
          width: 173,
          height: 43,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: simpanColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onSimpan,
            child: Text(
              simpanLabel,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
