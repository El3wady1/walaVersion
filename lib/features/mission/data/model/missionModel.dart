class MissionModel {
  final String id;
  final String info;
  final Department department;
  final DateTime createdAt;
  final DateTime updatedAt;

  MissionModel({
    required this.id,
    required this.info,
    required this.department,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is Map && value.containsKey("\$date")) {
        return DateTime.parse(value["\$date"]);
      } else {
        return DateTime.now(); // fallback
      }
    }

    return MissionModel(
      id: json['_id'] ?? '',
      info: json['info'] ?? '',
      department: Department.fromJson(json['department'] ?? {}),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }
}

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
