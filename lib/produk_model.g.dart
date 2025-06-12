// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produk_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProdukModelAdapter extends TypeAdapter<ProdukModel> {
  @override
  final int typeId = 1;

  @override
  ProdukModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProdukModel(
      nama: fields[0] as String,
      kode: fields[1] as String,
      nutrisi: fields[2] as String,
      tambahan: fields[3] as String,
      risiko: fields[4] as String,
      preferensiNutrisi: (fields[5] as Map).cast<String, bool>(),
      takaranKemasan: fields[6] as double,
      sajianPerKemasan: fields[7] as double,
      gambarPath: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProdukModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.nama)
      ..writeByte(1)
      ..write(obj.kode)
      ..writeByte(2)
      ..write(obj.nutrisi)
      ..writeByte(3)
      ..write(obj.tambahan)
      ..writeByte(4)
      ..write(obj.risiko)
      ..writeByte(5)
      ..write(obj.preferensiNutrisi)
      ..writeByte(6)
      ..write(obj.takaranKemasan)
      ..writeByte(7)
      ..write(obj.sajianPerKemasan)
      ..writeByte(8)
      ..write(obj.gambarPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProdukModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
