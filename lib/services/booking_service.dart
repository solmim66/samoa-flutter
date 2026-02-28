import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  static final _db = FirebaseFirestore.instance;
  static final _col = _db.collection('bookings');

  static Stream<List<BookingModel>> bookingsStream() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((d) => BookingModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  static Stream<List<BookingModel>> bookingsByUidStream(String uid) {
    return _col.where('uid', isEqualTo: uid).snapshots().map(
          (snap) => snap.docs
              .map((d) => BookingModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  static Future<void> cancelBooking(BookingModel booking) async {
    final batch = _db.batch();
    batch.update(_col.doc(booking.id), {'status': 'cancellata'});
    final eventRef = _db.collection('events').doc(booking.eventId);
    batch.update(eventRef, {
      'totalBooked': FieldValue.increment(-booking.guests),
      if (booking.isDinner) 'dinnerBooked': FieldValue.increment(-booking.guests),
    });
    await batch.commit();
  }

  static Future<void> confirmArrival(String bookingId) async {
    await _col.doc(bookingId).update({'status': 'presente'});
  }

  static Future<void> updateBooking({
    required BookingModel old,
    required Map<String, dynamic> newData,
    required int newGuests,
    required bool newIsDinner,
  }) async {
    final batch = _db.batch();
    batch.update(_col.doc(old.id), {...newData, 'status': 'modificata'});
    final eventRef = _db.collection('events').doc(old.eventId);

    final guestDelta = newGuests - old.guests;
    final Map<String, dynamic> eventUpdate = {
      'totalBooked': FieldValue.increment(guestDelta),
    };
    if (old.isDinner && !newIsDinner) {
      eventUpdate['dinnerBooked'] = FieldValue.increment(-old.guests);
    } else if (!old.isDinner && newIsDinner) {
      eventUpdate['dinnerBooked'] = FieldValue.increment(newGuests);
    } else if (old.isDinner && newIsDinner) {
      eventUpdate['dinnerBooked'] = FieldValue.increment(guestDelta);
    }
    batch.update(eventRef, eventUpdate);
    await batch.commit();
  }
}
