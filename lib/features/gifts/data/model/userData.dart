import 'package:saladafactory/features/gifts/data/model/giftsModel.dart';
import 'package:saladafactory/features/gifts/data/model/nextlevelModel.dart';

class UserResponseModel {
  final String name;
  final String email;
  final String phone;
  final NextLevel nextLevel;
  final int currentpoints;
  final int pointsRLevel;
  final String role;
  final List<Department> department;
  final bool isVerified;
  final DateTime updatedAt;
  final DateTime createdAt;
  final DateTime lastLogin;

  final bool canAddProduct;
  final bool canRemoveProduct;
  final bool canaddProductIN;
  final bool canProduction;
  final bool canOrderProduction;
  final bool canReceive;
  final bool canSend;
  final bool canSupply;
  final bool canDamaged;
  final bool canEditLastSupply;
  final bool canEditLastOrderProduction;
  final bool canShowTawalf;
  final String appversion;
  final bool canaddRezoCahser;
  final bool canshowRezoCahser;
  final bool canshowCahserRezoPhoto;

  UserResponseModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.nextLevel,
    required this.currentpoints,
    required this.pointsRLevel,
    required this.role,
    required this.department,
    required this.isVerified,
    required this.updatedAt,
    required this.createdAt,
    required this.lastLogin,
    required this.canAddProduct,
    required this.canRemoveProduct,
    required this.canaddProductIN,
    required this.canProduction,
    required this.canOrderProduction,
    required this.canReceive,
    required this.canSend,
    required this.canSupply,
    required this.canDamaged,
    required this.canEditLastSupply,
    required this.canEditLastOrderProduction,
    required this.canShowTawalf,
    required this.appversion,
    required this.canaddRezoCahser,
    required this.canshowRezoCahser,
    required this.canshowCahserRezoPhoto,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      nextLevel: NextLevel.fromJson(json['nextLevel']),
      currentpoints: json['currentpoints'] ?? 0,
      pointsRLevel: json['pointsRLevel'] ?? 0,
      role: json['role'] ?? '',
      department: (json['department'] as List? ?? [])
          .map((e) => Department.fromJson(e))
          .toList(),
      isVerified: json['isVerified'] ?? false,
      updatedAt: DateTime.parse(json['updatedAt']),
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
      canAddProduct: json['canAddProduct'] ?? false,
      canRemoveProduct: json['canRemoveProduct'] ?? false,
      canaddProductIN: json['canaddProductIN'] ?? false,
      canProduction: json['canProduction'] ?? false,
      canOrderProduction: json['canOrderProduction'] ?? false,
      canReceive: json['canReceive'] ?? false,
      canSend: json['canSend'] ?? false,
      canSupply: json['canSupply'] ?? false,
      canDamaged: json['canDamaged'] ?? false,
      canEditLastSupply: json['canEditLastSupply'] ?? false,
      canEditLastOrderProduction:
          json['canEditLastOrderProduction'] ?? false,
      canShowTawalf: json['canShowTawalf'] ?? false,
      appversion: json['Appversion'] ?? '',
      canaddRezoCahser: json['canaddRezoCahser'] ?? false,
      canshowRezoCahser: json['canshowRezoCahser'] ?? false,
      canshowCahserRezoPhoto:
          json['canshowCahserRezoPhoto'] ?? false,
    );
  }
}


