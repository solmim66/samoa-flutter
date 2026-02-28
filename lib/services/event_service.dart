import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  static final _db = FirebaseFirestore.instance;
  static final _col = _db.collection('events');

  static Stream<List<EventModel>> eventsStream() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((d) => EventModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  static Future<void> addEvent(Map<String, dynamic> data) async {
    await _col.add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  static Future<void> deleteEvent(String id) async {
    await _col.doc(id).delete();
  }

  static Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  static Future<void> confirmBooking({
    required String eventId,
    required Map<String, dynamic> bookingData,
    required int guests,
    required bool isDinner,
  }) async {
    final batch = _db.batch();
    final bookingRef = _db.collection('bookings').doc();
    batch.set(bookingRef, {
      ...bookingData,
      'createdAt': FieldValue.serverTimestamp(),
    });
    final eventRef = _col.doc(eventId);
    batch.update(eventRef, {
      'totalBooked': FieldValue.increment(guests),
      if (isDinner) 'dinnerBooked': FieldValue.increment(guests),
    });
    await batch.commit();
  }
}
