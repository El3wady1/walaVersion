import 'dart:convert';

class GiftsModel {
  final List<Gift> data;
  final int itemsnumber;
  final int status;

  GiftsModel({
    required this.data,
    required this.itemsnumber,
    required this.status,
  });

  factory GiftsModel.fromJson(Map<String, dynamic> json) {
    return GiftsModel(
      data: (json['data'] as List? ?? [])
          .map((x) => Gift.fromJson(Map<String, dynamic>.from(x)))
          .toList(),
      itemsnumber: int.tryParse(json['itemsnumber']?.toString() ?? '0') ?? 0,
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,
    );
  }
}

class Gift {
  final String id;
  final String title;
  final String description;
  final String image;
  final List<GiftDepartment> departments;
  final List<GiftCategory> categories;
  final DateTime createdAt;
  final DateTime updatedAt;

  Gift({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.departments,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['des'] ?? '',
      image: json['image'] ?? '',
      departments: (json['departments'] as List? ?? [])
          .map((x) => GiftDepartment.fromJson(Map<String, dynamic>.from(x)))
          .toList(),
      categories: (json['categories'] as List? ?? [])
          .map((x) => GiftCategory.fromJson(Map<String, dynamic>.from(x)))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class GiftDepartment {
  final Department department;
  final bool display;
  final String id;

  GiftDepartment({
    required this.department,
    required this.display,
    required this.id,
  });

  factory GiftDepartment.fromJson(Map<String, dynamic> json) {
    final dept = json['department'];

    Department departmentObj;

    if (dept is String) {
      departmentObj = Department(
        id: dept,
        name: '',
        slug: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (dept is Map) {
      departmentObj = Department.fromJson(Map<String, dynamic>.from(dept));
    } else {
      departmentObj = Department(
        id: '',
        name: '',
        slug: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return GiftDepartment(
      department: departmentObj,
      display: json['display'] ?? false,
      id: json['_id'] ?? '',
    );
  }
}

class Department {
  final String id;
  final String name;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;

  Department({
    required this.id,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class GiftCategory {
  final Category category;
  final int points;
  final String id;

  GiftCategory({
    required this.category,
    required this.points,
    required this.id,
  });

  factory GiftCategory.fromJson(Map<String, dynamic> json) {
    final cat = json['category'];
    Category categoryObj;

    if (cat is String) {
      categoryObj = Category(id: cat, name: '');
    } else if (cat is Map) {
      categoryObj = Category.fromJson(Map<String, dynamic>.from(cat));
    } else {
      categoryObj = Category(id: '', name: '');
    }

    return GiftCategory(
      category: categoryObj,
      points: int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      id: json['_id'] ?? '',
    );
  }
}

class Category {
  final String id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
