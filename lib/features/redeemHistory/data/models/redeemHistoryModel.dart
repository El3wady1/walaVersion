import 'package:flutter/material.dart';

// ------------------------ RedeemHistoryModel ------------------------

class RedeemHistoryModel {
  final int status;
  final int number; // أو results حسب الـ API
  final List<RedeemItem> data;

  RedeemHistoryModel({
    required this.status,
    required this.data,
    required this.number,
  });

  factory RedeemHistoryModel.fromJson(Map<String, dynamic> json) {
    return RedeemHistoryModel(
      status: json['status'] ?? 0,
      number: json['number'] ?? json['results'] ?? 0, // يدعم number أو results
      data: (json['data'] as List? ?? [])
          .map((e) => RedeemItem.fromJson(e))
          .toList(),
    );
  }
}

// ------------------------ RedeemItem ------------------------

class RedeemItem {
  final String id;
  final String title; // ✅ دايمًا String
  final String status;
  final String rate;
  final bool collect;
  final int points;
  final String place;
  final RedeemUser? userId;
  final String trxId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RedeemItem({
    required this.id,
    required this.title,
    required this.status,
    required this.rate,
    required this.collect,
    required this.points,
    required this.place,
    required this.userId,
    required this.trxId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RedeemItem.fromJson(Map<String, dynamic> json) {
    String parsedTitle = '';

    // ✅ حل مشكلة title يمكن يكون String أو Object
    if (json['title'] is String) {
      parsedTitle = json['title'];
    } else if (json['title'] is Map) {
      parsedTitle = json['title']['title'] ?? '';
    }

    return RedeemItem(
      id: json['_id'] ?? '',
      title: parsedTitle,
      status: json['status'] ?? '',
      rate: json['rate'] ?? '-',
      collect: json['collect'] ?? false,
      points: json['points'] ?? 0,
      place: json['place'] ?? '',
      userId:
          json['userId'] != null ? RedeemUser.fromJson(json['userId']) : null,
      trxId: json['trxId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

// ------------------------ RedeemUser ------------------------

class RedeemUser {
  final String id;
  final String name;

  RedeemUser({
    required this.id,
    required this.name,
  });

  factory RedeemUser.fromJson(Map<String, dynamic> json) {
    return RedeemUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
