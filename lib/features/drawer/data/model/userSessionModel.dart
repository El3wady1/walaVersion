class Department {
  final String id;
  final String name;

  Department({
    required this.id,
    required this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

// ------------------------

class UserModel {
  final String name;
  final String slug;
  final String email;
  final String phone;
  final String role;
  final List<Department> department;
  final bool isVerified;
  final DateTime updatedAt;
  final DateTime createdAt;
  final DateTime lastLogin;

  final bool canAddProduct;
  final bool canRemoveProduct;
  final bool canAddProductIN;
  final bool canProduction;
  final bool canOrderProduction;
  final bool canReceive;
  final bool canSend;
  final bool canSupply;
  final bool canDamaged;
  final bool canEditLastSupply;
  final bool canEditLastOrderProduction;
  final bool canShowTawalf;

  final String appVersion;
  final bool canAddRezoCahser;
  final bool canShowRezoCahser;
  final bool canShowCahserRezoPhoto;

  UserModel({
    required this.name,
    required this.slug,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.isVerified,
    required this.updatedAt,
    required this.createdAt,
    required this.lastLogin,
    required this.canAddProduct,
    required this.canRemoveProduct,
    required this.canAddProductIN,
    required this.canProduction,
    required this.canOrderProduction,
    required this.canReceive,
    required this.canSend,
    required this.canSupply,
    required this.canDamaged,
    required this.canEditLastSupply,
    required this.canEditLastOrderProduction,
    required this.canShowTawalf,
    required this.appVersion,
    required this.canAddRezoCahser,
    required this.canShowRezoCahser,
    required this.canShowCahserRezoPhoto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      department: (json['department'] as List<dynamic>? ?? [])
          .map((e) => Department.fromJson(e))
          .toList(),
      isVerified: json['isVerified'] ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: DateTime.parse(json['lastLogin'] ?? DateTime.now().toIso8601String()),
      canAddProduct: json['canAddProduct'] ?? false,
      canRemoveProduct: json['canRemoveProduct'] ?? false,
      canAddProductIN: json['canaddProductIN'] ?? false,
      canProduction: json['canProduction'] ?? false,
      canOrderProduction: json['canOrderProduction'] ?? false,
      canReceive: json['canReceive'] ?? false,
      canSend: json['canSend'] ?? false,
      canSupply: json['canSupply'] ?? false,
      canDamaged: json['canDamaged'] ?? false,
      canEditLastSupply: json['canEditLastSupply'] ?? false,
      canEditLastOrderProduction: json['canEditLastOrderProduction'] ?? false,
      canShowTawalf: json['canShowTawalf'] ?? false,
      appVersion: json['Appversion'] ?? '',
      canAddRezoCahser: json['canaddRezoCahser'] ?? false,
      canShowRezoCahser: json['canshowRezoCahser'] ?? false,
      canShowCahserRezoPhoto: json['canshowCahserRezoPhoto'] ?? false,
    );
  }
}
