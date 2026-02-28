import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String eventId;
  final String customerName;
  final String email;
  final String uid;
  final String option; // 'entrance' | 'dinner'
  final int guests;
  final String notes;
  final String status;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.eventId,
    required this.customerName,
    required this.email,
    required this.uid,
    required this.option,
    required this.guests,
    required this.notes,
    required this.status,
    this.createdAt,
  });

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      option: map['option'] as String? ?? 'entrance',
      guests: (map['guests'] as num?)?.toInt() ?? 1,
      notes: map['notes'] as String? ?? '',
      status: map['status'] as String? ?? 'confirmed',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isDinner => option == 'dinner';
}
