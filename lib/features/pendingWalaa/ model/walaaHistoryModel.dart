class PendinngWalaaHistoryModel {
  final int status;
  final int results;
  final List<WalaaHistoryModel> data;

  PendinngWalaaHistoryModel({
    required this.status,
    required this.results,
    required this.data,
  });

  factory PendinngWalaaHistoryModel.fromJson(Map<String, dynamic> json) {
    return PendinngWalaaHistoryModel(
      status: json['status'] ?? 0,
      results: json['results'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => WalaaHistoryModel.fromJson(e))
          .toList(),
    );
  }
}

class WalaaHistoryModel {
  final String id;
  final String? title;
  final String status;
  final String rate;
  final bool collect;
  final int points;
  final String place;
  final UserModel? user;
  final String trxId;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalaaHistoryModel({
    required this.id,
    this.title,
    required this.status,
    required this.rate,
    required this.collect,
    required this.points,
    required this.place,
    this.user,
    required this.trxId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalaaHistoryModel.fromJson(Map<String, dynamic> json) {
    // Safely handle title
    String? titleValue;
    if (json['title'] != null) {
      if (json['title'] is Map<String, dynamic>) {
        titleValue = json['title']['title'] ?? "";
      } else if (json['title'] is String) {
        titleValue = json['title'];
      }
    }

    // Safely handle user
    UserModel? userValue;
    if (json['userId'] != null && json['userId'] is Map<String, dynamic>) {
      userValue = UserModel.fromJson(json['userId']);
    }

    return WalaaHistoryModel(
      id: json['_id'] ?? "",
      title: titleValue,
      status: json['status'] ?? "",
      rate: json['rate'] ?? "",
      collect: json['collect'] ?? false,
      points: json['points'] ?? 0,
      place: json['place'] ?? "",
      user: userValue,
      trxId: json['trxId'] ?? "",
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class TitleModel {
  final String id;
  final String title;

  TitleModel({
    required this.id,
    required this.title,
  });

  factory TitleModel.fromJson(Map<String, dynamic> json) {
    return TitleModel(
      id: json['_id'] ?? "",
      title: json['title'] ?? "",
    );
  }
}

class UserModel {
  final String id;
  final String name;

  UserModel({
    required this.id,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
    );
  }
}
