class NextLevel {
  final String id;
  final String levelName;
  final int levelPoint;
  final DateTime createdAt;
  final DateTime updatedAt;

  NextLevel({
    required this.id,
    required this.levelName,
    required this.levelPoint,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NextLevel.fromJson(Map<String, dynamic> json) {
    return NextLevel(
      id: json['_id'],
      levelName: json['levelName'],
      levelPoint: json['levelPoint'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}