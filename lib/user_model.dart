import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String email;

  @HiveField(2)
  String password;

  @HiveField(3)
  int? usia;

  @HiveField(4)
  String? gender;

  @HiveField(5)
  String? penyakit;

  @HiveField(6)
  String? telepon;

  UserModel({
    required this.username,
    required this.email,
    required this.password,
    this.usia,
    this.gender,
    this.penyakit,
    this.telepon,
  });
}