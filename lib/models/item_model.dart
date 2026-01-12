import 'dart:convert';

enum ItemStatus { pending, purchased, skipped }

class ItemModel {
  final String id;
  final String name;
  final double price;
  final DateTime date;
  final DateTime createdAt;
  final ItemStatus status;
  final DateTime? completedAt;

  ItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.date,
    required this.createdAt,
    required this.status,
    this.completedAt,
  });

  ItemModel copyWith({
    String? id,
    String? name,
    double? price,
    DateTime? date,
    DateTime? createdAt,
    ItemStatus? status,
    DateTime? completedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: ItemStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ItemStatus.pending,
      ),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ItemModel.fromJsonString(String jsonString) {
    return ItemModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  bool get isPending => status == ItemStatus.pending;
  bool get isPurchased => status == ItemStatus.purchased;
  bool get isSkipped => status == ItemStatus.skipped;

  Duration get timeElapsed => DateTime.now().difference(createdAt);
  bool get is24HoursElapsed => timeElapsed.inHours >= 24;

  Duration get timeRemaining {
    final deadline = createdAt.add(const Duration(hours: 24));
    final remaining = deadline.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
