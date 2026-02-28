import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String date;
  final String day;
  final String description;
  final String dj;
  final String time;
  final String dinnerTime;
  final String dinnerPrice;
  final String entrancePrice;
  final int dinnerSeats;
  final int totalSeats;
  final int dinnerBooked;
  final int totalBooked;
  final List<String> tags;
  final String color;
  final String imageUrl;
  final DateTime? createdAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.day,
    required this.description,
    required this.dj,
    required this.time,
    required this.dinnerTime,
    required this.dinnerPrice,
    required this.entrancePrice,
    required this.dinnerSeats,
    required this.totalSeats,
    required this.dinnerBooked,
    required this.totalBooked,
    required this.tags,
    required this.color,
    this.imageUrl = '',
    this.createdAt,
  });

  factory EventModel.fromMap(String id, Map<String, dynamic> map) {
    return EventModel(
      id: id,
      title: map['title'] as String? ?? '',
      date: map['date'] as String? ?? '',
      day: map['day'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dj: map['dj'] as String? ?? '',
      time: map['time'] as String? ?? '',
      dinnerTime: map['dinnerTime'] as String? ?? '20:00',
      dinnerPrice: map['dinnerPrice'] as String? ?? '€0',
      entrancePrice: map['entrancePrice'] as String? ?? '€0',
      dinnerSeats: (map['dinnerSeats'] as num?)?.toInt() ?? 0,
      totalSeats: (map['totalSeats'] as num?)?.toInt() ?? 0,
      dinnerBooked: (map['dinnerBooked'] as num?)?.toInt() ?? 0,
      totalBooked: (map['totalBooked'] as num?)?.toInt() ?? 0,
      tags: List<String>.from(map['tags'] as List? ?? []),
      color: map['color'] as String? ?? '#4A1A6B',
      imageUrl: map['imageUrl'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'date': date,
    'day': day,
    'description': description,
    'dj': dj,
    'time': time,
    'dinnerTime': dinnerTime,
    'dinnerPrice': dinnerPrice,
    'entrancePrice': entrancePrice,
    'dinnerSeats': dinnerSeats,
    'totalSeats': totalSeats,
    'dinnerBooked': dinnerBooked,
    'totalBooked': totalBooked,
    'tags': tags,
    'color': color,
    'imageUrl': imageUrl,
  };

  bool get soldOut => totalBooked >= totalSeats;
  bool get dinnerSoldOut => dinnerBooked >= dinnerSeats;
  int get availableSeats => totalSeats - totalBooked;
  double get availabilityPct => totalSeats > 0 ? totalBooked / totalSeats : 0;

  int get entrancePriceInt {
    final s = entrancePrice.replaceAll('€', '').trim();
    return int.tryParse(s) ?? 0;
  }

  int get dinnerPriceInt {
    final s = dinnerPrice.replaceAll('€', '').trim();
    return int.tryParse(s) ?? 0;
  }
}
